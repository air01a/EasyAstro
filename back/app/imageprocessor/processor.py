from ..models.image import Image
import logging
from ..models.image import Image

from ..imageprocessor.utils import  open_process_fits, save_jpeg,  normalize, save_to_bytes
from ..imageprocessor.filters import stretch, stretch, levels
from ..imageprocessor.align import find_transformation, apply_transformation
from ..imageprocessor.stack import stack_image

logger = logging.getLogger(__name__)


class ImageProcessor:

    stretch = 0.18
    whites = 65535
    blacks = 1
    mids = 1
    contrast = 1
    r = 1
    g = 1
    b = 1
    stretch_algo = 1

    def __init__(self):
        self.last_image=None
        self.last_image_processed=None

    def process_last_image(self, process=True, size=1):
        ret = self.last_image.clone()
        
        if (self.stretch > 0):
            stretch(ret,self.stretch, self.stretch_algo)
        
        if (process):    
            levels(ret, self.blacks,self.mids,self.whites, self.contrast, self.r, self.g, self.b)
        
        ret = normalize(ret)
        img_bytes = save_to_bytes(ret,'JPG', size)
        return img_bytes.getvalue()

    def set_image_processing(self, stretch_algo, stretch, blacks, midtones, whites, contrast, r, g, b):
        self.stretch=stretch
        self.whites = whites
        self.blacks = blacks
        self.mids = midtones
        self.r = r
        self.g = g
        self.b = b
        self.contrast = contrast
        self.stretch_algo = stretch_algo


    def get_image_processing(self):
        return {"stretchAlgo":self.stretch_algo, "contrast":self.contrast, "stretch": self.stretch, "whites":self.whites, "blacks":self.blacks, "mids":self.mids, "r":self.r, "g":self.g, "b":self.b}



    def set_last_image(self, filename):
        self.last_image = open_process_fits(filename)
