from fastapi import FastAPI
from fastapi.responses import RedirectResponse
from fastapi.middleware.cors import CORSMiddleware
import logging
from fastapi.staticfiles import StaticFiles
import uvicorn
from uvicorn.main import Server
import sys
import asyncio
import os
import signal

from .dependencies import config


from .router import (
    platesolver,
    telescope,
)   



original_handler = Server.handle_exit
level = logging.DEBUG
for handler in logging.root.handlers[:]:
    logging.root.removeHandler(handler) 
logging.basicConfig(filename = '/tmp/easyastro.log', filemode='w', level=level)
logger = logging.getLogger(__name__)
logger.info('STARTING')

app = FastAPI()
origins = [
    "*"
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

@app.get("/stop")
def stop():
    os.kill(os.getpid(), signal.SIGINT)



app.include_router(platesolver.router, prefix='/platesolver')
app.include_router(telescope.router, prefix='/telescope')
app.mount("/static", StaticFiles(directory="static"), name="static")

def handle_exit(*args, **kwargs):
    print("stopping server")
    telescope.telescope.stop()
    telescope.continue_job=False
    original_handler(*args, **kwargs)


def run():
    Server.handle_exit = handle_exit
    uvicorn.run("app.main:app", host=config.CONFIG['HTTP']['HOST'], port=int(config.CONFIG['HTTP']['PORT']), reload=False)