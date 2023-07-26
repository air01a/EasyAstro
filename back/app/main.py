from fastapi import FastAPI
from fastapi.responses import RedirectResponse
from fastapi.middleware.cors import CORSMiddleware
import logging
from fastapi.staticfiles import StaticFiles

import uvicorn

from .router import (
    platesolver,
    telescope,
)   

level = logging.DEBUG
for handler in logging.root.handlers[:]:
    logging.root.removeHandler(handler) 
logging.basicConfig(filename = '/tmp/easyastro.log', filemode='w', level=level)
logger = logging.getLogger(__name__)
logger.info('STARTING')

app = FastAPI()
origins = [
    "*",
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

@app.get("/")
async def redirect():
    response = RedirectResponse(url='/static/index.html')
    return response

app.include_router(platesolver.router, prefix='/platesolver')
app.include_router(telescope.router, prefix='/telescope')
app.mount("/static", StaticFiles(directory="static"), name="static")


def run():
    uvicorn.run("app.main:app", host="0.0.0.0", port=8001, reload=False)