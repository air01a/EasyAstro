from pydantic import BaseModel, Json, Field

class TimeObject(BaseModel):
    time: str = Field(description="String time format Y-m-d H:M")

class Coord(BaseModel):
    lon: float
    lat: float
    height : float

class StarCoord(BaseModel):
    ra: float
    dec: float
    object: str

class Exposition(BaseModel):
    exposition: str = Field(description="Exposure time in sec, str format : 0.01, 3, ...")


class Movement(BaseModel):
    axis1: float
    axis2: float
