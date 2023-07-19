from pydantic import BaseModel

class TelescopeInfo(BaseModel):
    current_task : str = 'IDLE'
    ra : float = 0.0
    dec : float = 0.0
    object: str = ''
    processing: bool = False
    stacking: bool = False
    exposition: float = 2.0
    last_error: int = 0
    ccd_orientation : float = 0.0
    stacked: int = 0
    discarded : int = 0


