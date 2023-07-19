from fastapi import APIRouter, WebSocket,  Body
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
from ..models.coordinates import Exposition, Movement
from ..models.processing import ImageProcessing
from ..imageprocessor.processor import ImageProcessor
from datetime import datetime,date
from ..models.coordinates import TimeObject

router = APIRouter()
logger = logging.getLogger(__name__)
ImageFile.LOAD_TRUNCATED_IMAGES = True


processor = ImageProcessor()
telescope = telescope.TelescopeOrchestrator(processor,True)

@router.post("/location") 
async def set_coord(coord : Coordinates.Coord):
    telescope.coordinates.set_location_coord(coord.lat, coord.lon, coord.height)
    return error.no_error()

@router.post("/time")
async def set_time(time: TimeObject):
    telescope.coordinates.set_time(telescope.coordinates.time_local_to_utc(datetime.strptime(time.time,"%Y-%m-%d %H:%M")))
    return error.no_error()

@router.post("/goto")   
async def goto(coord : Coordinates.StarCoord):
    return telescope.move_to(coord.ra, coord.dec, coord.object)

@router.post("/processing")   
async def processing(processing : ImageProcessing):
    return processor.set_image_processing(processing.stretchAlgo, processing.stretch, processing.blacks, processing.midtones, processing.whites, processing.contrast, processing.r, processing.g, processing.b)

@router.get("/processing")
async def get_processing():
    return processor.get_image_processing()

@router.post("/move")   
async def goto(coord : Movement):
    return telescope.move_short(coord.axis1, coord.axis2)

@router.get('/picture')
def picture(exposure: int, gain: int):
    return telescope.take_picture(exposure, gain)

@router.get('/status')
async def get_status():
    return telescope.get_status()

@router.get('/operation')
async def get_status():
    return telescope.get_status()

@router.get('/last_picture')
def last_picture(process: bool = True, size: float = 1):
    img_bytes = processor.process_last_image(process, size)
    
    headers = {
        "Content-Disposition": "inline",
        "filename": "image.jpg",
        "Content-Type": "image/jpg",
    }
    return Response(content=img_bytes, headers=headers)
    #return Response(content=img_bytes, media_type="image/jpeg")

@router.get('/take_dark')
def take_dark():
    return telescope.take_dark()

@router.get('/get_dark_progress')
def get_dark_progress():
    return telescope.get_dark_progress()
    
@router.post('/stop_stacking')
def get_dark_progress():
    return telescope.stop_stacking()


@router.post('/stacking')
async def stacking(coord : Coordinates.StarCoord):
    telescope.stack(coord.ra, coord.dec, coord.object)

@router.post('/exposition')
async def exposition(exposition : Exposition):
    if exposition.exposition==-1.0:
        telescope.set_exposition_auto()
    else:
        try:
            telescope.change_exposition(exposition.exposition)
        except:
            telescope.set_exposition_auto()
    telescope.set_gain(exposition.gain)


class ConnectionManager:
    def __init__(self):
        self.connections = []

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
            await manager.broadcast(f"{data}")
        await asyncio.sleep(1)