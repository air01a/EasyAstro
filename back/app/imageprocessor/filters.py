import numpy
from ..models.image import Image
from scipy.signal import convolve2d
from ..models.constants import I16_BITS_MAX_VALUE, HOT_PIXEL_RATIO
from .gradient import max_type
import logging
from .stretch import Stretch

logger = logging.getLogger(__name__)
def sharpen(image):
    kernel = numpy.array([[-1,-1,-1], [-1,9,-1], [-1,-1,-1]])
    for channel in range(3):
        image.data[channel] = convolve2d(image.data[channel], kernel, mode='same', boundary='fill', fillvalue=0)

def _neighbors_average(data):
    """
    returns an array containing the means of all original array's pixels' neighbors
    :param data: the image to compute means for
    :return: an array containing the means of all original array's pixels' neighbors
    :rtype: numpy.Array
    """

    kernel = numpy.ones((3, 3))
    kernel[1, 1] = 0

    neighbor_sum = convolve2d(data, kernel, mode='same', boundary='fill', fillvalue=0)
    num_neighbor = convolve2d(numpy.ones(data.shape), kernel, mode='same', boundary='fill', fillvalue=0)

    return (neighbor_sum / num_neighbor).astype(data.dtype)


def hot_pixel_remover(image: Image):

    # the idea is to check every pixel value against its 8 neighbors
    # if its value is more than _HOT_RATIO times the mean of its neighbors' values
    # me replace its value with that mean

    # this can only work on B&W or non-debayered color images

    if not image:
        return None

    if not image.is_color():
        means = _neighbors_average(image.data)
        print(means)
        #if means!=0:
        try:
            image.data = numpy.where(image.data / means > HOT_PIXEL_RATIO, means, image.data)
        except Exception as exc:
            logger.error("Error during hotpixelremover :( %s"%str(exc))
    else:
        print("Hot Pixel Remover cannot work on debayered color images.")


def color_balance(image : Image, red : float, green : float, blue: float):
    # red, green, blue : float 0-2
    image.data[0] = image.data[0] * red
    image.data[1] = image.data[1] * green
    image.data[2] = image.data[2] * blue
    image.data = numpy.clip(image.data, 0, 2**16 - 1)

def levels(image : Image, black: float, midtones: float, white: float):
    # mids : 0-2
    # black : int 0-max(int)
    # white : int 0-max(int)
    
    # midtones
    image.data = I16_BITS_MAX_VALUE * image.data ** (1 / midtones) / I16_BITS_MAX_VALUE ** (1 / midtones)
    # black / white levels
    image.data = numpy.clip(image.data, black, white)

    image.data = numpy.float32(numpy.interp(image.data,
                                            (image.data.min(), image.data.max()),
                                            (0, I16_BITS_MAX_VALUE)))
    


def gammaCorrection(img_data, gamma):
    '''
    gammaCorrection(img_data(2 or 3D numpy.ndarray), gamma(float))
    Apply gamma correction to input image according to
        f(x) = (x / max_in_dtype) ** gamma * max_in_dtype
    img_data: 2 or 3D numpy.ndarray, the input image data
    gamma: float, the gamma value
    '''
    # Build up a look-up table for numpy.uint8 and uint16
    if img_data.dtype == numpy.uint8 or img_data.dtype == numpy.uint16:
        imax = max_type(img_data.dtype)
        lut = numpy.linspace(0, imax, imax + 1, dtype=numpy.float32) / imax
        lut = numpy.clip(numpy.power(lut, gamma) * imax, 0, imax)
        lut = lut.astype(img_data.dtype, copy=False)
        return numpy.take(lut, img_data)
    else:
        return numpy.clip(numpy.power(img_data, gamma), 0.0, 1.0)
    
def stretch(image : Image, strength : float):
    # strength float : 0-1
    image.data = numpy.interp(image.data,
                                   (image.data.min(), image.data.max()),
                                   (0, I16_BITS_MAX_VALUE))
    if image.is_color():
        for channel in range(3):
            image.data[channel] = Stretch(target_bkg=strength).stretch(image.data[channel])
        else:
            image.data = Stretch(target_bkg=strength).stretch(image.data)
    image.data *= I16_BITS_MAX_VALUE