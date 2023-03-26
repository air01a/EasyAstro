from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from load_catalog import Load_Catalog
from coordinates import Coordinates,Coord
from datetime import datetime
from enum import Enum

catalog = Load_Catalog()
catalog.open('data/deepsky.lst')
coordinates = Coordinates()


app = FastAPI()
origins = [
    "http://localhost:5173",
    "http://localhost:8000",
    "http://localhost:3000",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def no_error():
    return {'error_code':0}

@app.post("/location/coord")
async def set_coord(coord : Coord):
    coordinates.set_location_coord(coord.lat, coord.lon, coord.height)
    return no_error()

@app.post("/location/time")
async def set_time(time : str):
    coordinates.set_time(coordinates.time_local_to_utc(datetime.strptime(time,"%Y-%m-%d %H:%M")))
    return no_error()

@app.get("/visible/")
def visible():
    coordinates.set_constraints();
    coordinates.get_catalog_visibility(catalog)
    return coordinates.get_catalog_visibility(catalog)

@app.get("/")
async def root():
    return [{"name": "Hello World","age": 10, "email": "test@test.com"},{"name": "mike","age": 20, "email": "test2@test.com"},{"name": "Kevin","age": 15, "email": "test3@test.com"}]
   
"""

class ModelName(str, Enum):
    alexnet = "alexnet"
    resnet = "resnet"
    lenet = "lenet"
    
@app.get("/models/{model_name}")
async def get_model(model_name: ModelName):
    if model_name is ModelName.alexnet:
        return {"model_name": model_name, "message": "Deep Learning FTW!"}

    if model_name.value == "lenet":
        return {"model_name": model_name, "message": "LeCNN all the images"}

    return {"model_name": model_name, "message": "Have some residuals"}

@app.get("/")
async def root():
    return [{"name": "Hello World","age": 10, "email": "test@test.com"},{"name": "mike","age": 20, "email": "test2@test.com"},{"name": "Kevin","age": 15, "email": "test3@test.com"}]
    
@app.get("/test/{id}")
async def test(id : int) : 
    return {"id":str(id)}
    

    """
