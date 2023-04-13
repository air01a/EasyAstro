from fastapi import APIRouter, WebSocket
from ..telescope import telescope
from ..dependencies import error
from ..lib import fitsutils
from PIL import Image
from astropy.io import fits
from fastapi.responses import Response
import numpy
import math
from io import BytesIO


router = APIRouter()
telescope = telescope.IndiOrchestrator()

@router.put("/goto/")   
async def goto(ra: float, dec : float):
    return telescope.move_to(ra, dec)

@router.get('/picture/')
def goto(exposure: int, gain: int):
    return telescope.take_picture(exposure, gain)




@router.get('/last_picture')
def last_picture():
    
    img_bytes = fitsutils.fits_to_jpg('/tmp/test.fits')
     
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

    async def broadcast(self, data: str):
        for connection in self.connections:
            await connection.send_text(data)

manager = ConnectionManager()

@router.websocket("/ws/{client_id}")
async def websocket_endpoint(websocket: WebSocket, client_id: int):
    await manager.connect(websocket)
    while True:
        data = await websocket.receive_text()
        await manager.broadcast(f"Client {client_id}: {data}")