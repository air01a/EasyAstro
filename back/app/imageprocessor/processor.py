from ..models.image import Image
import logging

from ..imageprocessor.utils import  open_process_fits, save_jpeg,  normalize, save_to_bytes
from ..imageprocessor.filters import stretch, stretch, levels
from ..imageprocessor.align import find_transformation, apply_transformation
from ..imageprocessor.stack import stack_image
import os
import random
import cv2

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

        jpg = [file for file in os.listdir('static/images/messier/') if file.endswith(".jpg")]
        random_file = random.choice(jpg)
        self.last_image = Image(cv2.imread('static/images/messier/'+random_file))
        self.last_image_processed = None
        self.image_stacking = None

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

    def init_stacking(self, filename):
        self.ref = open_process_fits(filename)
        self.image_stack = self.ref.clone()
        self.stacked = 1
        self.discarded = 0

    def stack(self, filename):
        image = open_process_fits(filename)
        logger.debug(' --- TRANSFORMING')
        transformation = find_transformation(image, self.ref)
        if transformation==None:
            logger.error("... No alignment point, skipping image %s ..." % (filename))
            self.discarded += 1
            return False
        else:
            logger.debug(' --- STACKING')
            apply_transformation(image, transformation, self.ref)
            stack_image(image, self.image_stack, self.stacked, 1)
            self.image_stack = image.clone()
            self.last_image = self.image_stack
            self.stacked += 1
            return True
