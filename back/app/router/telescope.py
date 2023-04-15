from fastapi import APIRouter, WebSocket
from ..telescope import telescope
from ..dependencies import error
from ..lib import fitsutils
from PIL import Image, ImageFile
from fastapi.responses import Response
from io import BytesIO
from ..lib import Coordinates
import os
import asyncio
import logging


router = APIRouter()
logger = logging.getLogger(__name__)
ImageFile.LOAD_TRUNCATED_IMAGES = True


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
    print(file_name, file_extension)
    if (file_extension=='.fits'):
        
        img_bytes = fitsutils.fits_to_png(telescope.last_image)
    else: 
        img_bytes_io = BytesIO()
        im = Image.open(telescope.last_image)
        im.save(img_bytes_io,format='PNG')
        img_bytes = img_bytes_io.getvalue() 
    
    headers = {
        "Content-Disposition": "inline",
        "filename": "image.png",
        "Content-Type": "image/png",
    }
    return Response(content=img_bytes, headers=headers)
    #return Response(content=img_bytes, media_type="image/jpeg")


class ConnectionManager:
    def __init__(self):
        self.connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.connections.append(websocket)

    async def broadcast(self, data: str):
        for connection in self.connections:
            try : 
                await connection.send_text(data)
            except: 
                logger.error("Error with Wss")



manager = ConnectionManager()

@router.websocket("/ws/{client_id}")
async def websocket_endpoint(websocket: WebSocket, client_id: int):
    await manager.connect(websocket)
    while True:
        if not telescope.qout.empty():
            data = telescope.qout.get()
        #data =  await asyncio.get_running_loop().run_in_executor(None, )()
            print("ws OK")
            await manager.broadcast(f"{data}")
        await asyncio.sleep(1)