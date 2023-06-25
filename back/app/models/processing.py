from pydantic import BaseModel

class ImageProcessing(BaseModel):
    contrast: float
    stretch: float
    r : float
    g : float
    b : float
    whites : int
    blacks : int
    midtones : int
