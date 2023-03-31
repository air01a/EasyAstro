from fastapi import APIRouter
from ..platesolve import platesolver
from ..dependencies import error


router = APIRouter()
plate_solver = platesolver.PlateSolve()

@router.get("/solve")
async def plate_solve(fits : str):
    return plate_solver.resolve(fits)
