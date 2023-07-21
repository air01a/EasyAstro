from ..models.image import Image
import logging

from ..imageprocessor.utils import  open_process_fits, save_jpeg,  normalize, save_to_bytes
from ..imageprocessor.filters import stretch, stretch, levels
from ..imageprocessor.align import find_transformation, apply_transformation
from ..imageprocessor.stack import stack_image
import os
import random
import cv2
from ..dependencies import error, config

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
    current_dark = None



    def __init__(self):

        jpg = [file for file in os.listdir('static/images/messier/') if file.endswith(".jpg")]
        random_file = random.choice(jpg)
        self.last_image = Image(cv2.imread('static/images/messier/'+random_file))
        self.last_image_processed = None
        self.image_stacking = None
        self.load_dark_library()



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

    def init_stacking(self, filename, expo, gain):
        self._dark = self.get_dark(expo,gain)

        self.ref = open_process_fits(filename)
        self.image_stack = self.ref.clone()
        print(self._dark)
        if self._dark!=None:
            print("substract dark")
            self.image_stack.data -= self._dark.data
            print("done")
        self.stacked = 1
        self.discarded = 0

    def stack(self, filename):
        image = open_process_fits(filename)
        print("substract dark")
        if self._dark!=None:
            image.data -= self._dark.data
        print("done")
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


    def get_dark_library(self):
        return self.dark_lib
    
    def get_current_dark(self):
        return self.current_dark
    
    def set_dark_library(self, path):
        dir = config.CONFIG["WORKFLOW"]["STORAGE_DIR"] + "/dark/" + path
        if os.path.exists(dir):
            self.current_dark = dir
        
    def get_dark_parameters(self):
        expositions = [1,3,5,10,15]
        gains = [50, 100, 150, 200]
        return (expositions,gains)
    
    def _select_best_option(self, tab, value):
        std = 10000
        indice = 0

        for i in range(0,len(tab)):
            std_tmp = abs(tab[i]**2-value**2)**0.5
            print(std_tmp)
            if (std_tmp)<std:
                std=std_tmp
                indice = i
        return tab[indice]

    def get_dark(self, exposition, gain):
        working_dir = self.current_dark
        if (working_dir==None):
            return None
        (expo_t, gain_t) = self.get_dark_parameters()
        selected_expo = self._select_best_option(expo_t, exposition)
        selected_gain = self._select_best_option(gain_t, gain)
        path = working_dir+'/dark_'+str(selected_expo)+'_'+str(selected_gain)+'.fits'
        print(""+str(exposition)+' '+str(gain))
        print("Selected Dark : " + path)
        if (os.path.isfile(path)):
            return open_process_fits(path)

        return None



    def load_dark_library(self):
        working_dir = config.CONFIG["WORKFLOW"]["STORAGE_DIR"] + "/dark/"
        dark_dir = [os.path.join(working_dir, name) for name in os.listdir(working_dir) if os.path.isdir(os.path.join(working_dir, name))]
        dark_dir.sort()  # Triez les sous-répertoires par ordre alphanumérique
        print(dark_dir)
        if len(dark_dir)>0:
            self.current_dark = dark_dir[-1]
            print("Current dark" + self.current_dark)
        else:
            self.current_dark = None
        self.dark_lib = dark_dir
