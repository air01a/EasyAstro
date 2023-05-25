from fastapi import APIRouter
from ..platesolve import platesolver
from ..dependencies import error


router = APIRouter()
plate_solver = platesolver.PlateSolveAstap()

@router.get("/solve")
def plate_solve(fits : str):
    return plate_solver.resolve(fits)
