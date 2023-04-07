from fastapi import APIRouter
from ..telescope import telescope
from ..dependencies import error


router = APIRouter()
telescope = telescope.IndiOrchestrator()

@router.put("/goto/")   
async def goto(ra: float, dec : float):
    return telescope.move_to(ra, dec)

@router.get('/picture/')
def goto(exposure: int, gain: int):
    return telescope.take_picture(exposure, gain)
