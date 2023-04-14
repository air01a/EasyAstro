from fastapi import APIRouter, WebSocket
from ..telescope import telescope
from ..dependencies import error
from ..lib import fitsutils
from PIL import Image
from fastapi.responses import Response
from io import BytesIO
from ..lib import Coordinates
import os
import asyncio

router = APIRouter()
telescope = telescope.IndiOrchestrator()

@router.post("/goto/")   
def goto(coord : Coordinates.StarCoord):
    return telescope.move_to(coord.ra, coord.dec)

@router.get('/picture/')
def goto(exposure: int, gain: int):
    return telescope.take_picture(exposure, gain)

@router.get('/status')
async def get_status():
    return telescope.processing

@router.get('/last_picture')
def last_picture():
    file_name, file_extension = os.path.splitext(telescope.last_image)
    if (file_extension=='fits'):
        img_bytes = fitsutils.fits_to_jpg()
    else: 
        img_bytes_io = BytesIO()
        im = Image.open(telescope.last_image)
        im.save(img_bytes_io,format='JPEG')
        img_bytes = img_bytes_io.getvalue() 
    
    headers = {
        "Content-Disposition": "inline",
        "filename": "image.jpg",
        "Content-Type": "image/jpeg",
    }
    return Response(content=img_bytes, headers=headers)
    #return Response(content=img_bytes, media_type="image/jpeg")


class ConnectionManager:
    def __init__(self):
        self.connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.connections.append(websocket)

    async def awaitbroadcast(self, data: str):
        for connection in self.connections:
            await connection.send_text(data)

manager = ConnectionManager()

@router.websocket("/ws/{client_id}")
async def websocket_endpoint(websocket: WebSocket, client_id: int):
    await manager.connect(websocket)
    while True:
        data =  await asyncio.get_running_loop().run_in_executor(None, telescope.qout.get())()
        print("ws OK")
        await manager.broadcast(f"Client {client_id}: {data}")