from ..imageprocessor.align import find_transformation, apply_transformation
from ..imageprocessor.stack import stack_image
from ..imageprocessor.utils import open_fits, open_process_fits, debayer, adapt, save_to_bytes, normalize, save_jpeg
from ..imageprocessor.filters import hot_pixel_remover, levels, stretch, color_balance
from ..imageprocessor.gradient import gridBackgroundRemove
from ..models.image import Image
from ..lib.fitsutils import sky_median_sig_clip
from ..telescope.telescope import IndiOrchestrator
import numpy as np
import os
import time

indi = IndiOrchestrator(False)
IMAGE_STACKING_PATH = 'image_test/'

def test_stacking(messier='m51'):
    path = IMAGE_STACKING_PATH+messier+'/'
    dirs = os.listdir( path )
    fits_list = []
    for file in dirs:
        filename, file_extension = os.path.splitext(file)
        if file_extension=='.fits':
            fits_list.append(path+file)
    i=1
    ref = open_process_fits(fits_list[0])
    stacked = ref.clone()
    
    while i<len(fits_list):
        print("traiting image %s" % (fits_list[i]))
        im2 = open_process_fits(fits_list[i])

        transformation = find_transformation(im2, ref)
        if transformation==None:
            print("... No alignment point, skipping image ...")
        else:
            print("Rotation: {:.2f} degrees".format(transformation.rotation * 180.0 / np.pi))
            print("\nScale factor: {:.2f}".format(transformation.scale))
            print("\nTranslation: (x, y) = ({:.2f}, {:.2f})".format(*transformation.translation))
            print("\nTranformation matrix:\n{}".format(transformation.params))
            apply_transformation(im2, transformation, ref)
            stack_image(im2,stacked,i, 1)
        i+=1

    levels(stacked, 1000, 1,65535)
    stretch(stacked, 0.18)
    color_balance(stacked, 1, 1, 1)
    stacked.data = gridBackgroundRemove(stacked.data)
    normalize(stacked)

    save_jpeg(stacked,IMAGE_STACKING_PATH+'result/'+messier+'.jpg')

def goto(ra, dec, solver):
    print("GOTO")
    indi._move_to(ra,dec, solver)

def move():
    indi.indi.move_short(0 ,0.1)

def take_picture(filename, exposure ):
    
    indi.indi.take_picture(filename,exposure,100)



if __name__ == "__main__":
    #test_stacking()
    #take_picture('/tmp/test.fits',1.0)
    #move()
    goto(168.771021, 55.037651, False)
    take_picture('tmp/test1.fits',1)
    time.sleep(2)
    move()
    take_picture('tmp/test2.fits',1)
    time.sleep(2)
    indi.shutdown()