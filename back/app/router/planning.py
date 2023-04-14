from fastapi import APIRouter, Query, Body
from ..lib import Coordinates
from ..lib import LoadCatalog
from ..dependencies import error
from datetime import datetime,date
from typing import List
from pydantic import BaseModel, Json, Field
from ..dependencies import config


class TimeObject(BaseModel):
    time: str = Field(description="String time format Y-m-d H:M")


router = APIRouter()
catalog = LoadCatalog.LoadCatalog()
catalog.open('data/deepsky.lst')
coordinates = Coordinates.Coordinates()
coordinates.set_location_coord(float(config.CONFIG["LOCATION"]["LAT"]),float(config.CONFIG["LOCATION"]["LON"]),float(config.CONFIG["LOCATION"]["HEIGHT"]))
today = str(date.today())
coordinates.set_time(coordinates.time_local_to_utc(datetime.strptime(today+" 23:59","%Y-%m-%d %H:%M")))


@router.post("") 
async def set_coord(coord : Coordinates.Coord):
    coordinates.set_location_coord(coord.lat, coord.lon, coord.height)
    return error.no_error()

@router.post("/time")
async def set_time(time: TimeObject):
    coordinates.set_time(coordinates.time_local_to_utc(datetime.strptime(time.time,"%Y-%m-%d %H:%M")))
    return error.no_error()

@router.get("/visible")
def visible():
    coordinates.set_constraints();
    coordinates.get_catalog_visibility(catalog)
    return coordinates.get_catalog_visibility(catalog)

@router.get("/objects/{obj_list}")
async def get_objects(obj_list : str):
    objects = obj_list.split(",")
    ret = coordinates.get_catalogs_objects(objects, catalog.catalog)
    return ret

@router.get("/object/{obj_name}")
async def get_objects(obj_name : str):
    ret = coordinates.get_object(obj_name)
    ra = ret.ra.hour
    dec = ret.dec.deg
    return [ra,dec]