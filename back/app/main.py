from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .router import (
    planning,
    platesolver,
)

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


app.include_router(planning.router, prefix='/planning')
app.include_router(platesolver.router, prefix='/platesolver')
