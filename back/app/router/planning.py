from fastapi import APIRouter
from ..lib import Coordinates
from ..lib import LoadCatalog
from ..dependencies import error
from datetime import datetime


router = APIRouter()
catalog = LoadCatalog.LoadCatalog()
catalog.open('data/deepsky.lst')
coordinates = Coordinates.Coordinates()

@router.post("")
async def set_coord(coord : Coordinates.Coord):
    coordinates.set_location_coord(coord.lat, coord.lon, coord.height)
    return error.no_error()

@router.post("/time")
async def set_time(time : str):
    coordinates.set_time(coordinates.time_local_to_utc(datetime.strptime(time,"%Y-%m-%d %H:%M")))
    return error.no_error()

@router.get("/visible")
def visible():
    coordinates.set_constraints();
    coordinates.get_catalog_visibility(catalog)
    return coordinates.get_catalog_visibility(catalog)
