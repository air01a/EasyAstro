import numpy
from astropy.io import fits
import cv2
#ImageFile.LOAD_TRUNCATED_IMAGES = True
from skimage.transform import SimilarityTransform

import astroalign as aa
from rawpy import imread
from stretch import Stretch
from scipy.signal import convolve2d

from PIL import Image as ImagePIL

from skimage.restoration import (denoise_tv_chambolle, denoise_bilateral,
                                 denoise_wavelet, estimate_sigma, richardson_lucy,rolling_ball)
_16_BITS_MAX_VALUE = 2**16 - 1
_HOT_PIXEL_RATIO = 2    



#___________________________________________________________________________________________________________________________
# Image object
#___________________________________________________________________________________________________________________________
class Image:

    UNDEF_EXP_TIME = -1
    """
    Represents an image, our basic processing object.
    Image data is a numpy array. Array's data type is unspecified for now
    but we'd surely benefit from enforcing one (float32 for example) as it will
    ease the development of any later processing code
    We also store the bayer pattern the image was shot with, if applicable.
    If image is from a sensor without a bayer array, the bayer pattern must be None.
    """

    def __init__(self, data):
        """
        Constructs an Image
        :param data: the image data
        :type data: numpy.ndarray
        """
        self._data = data
        self._bayer_pattern: str = ""
        self._origin: str = "UNDEFINED"
        self._destination: str = "UNDEFINED"
        self._ticket = ""
        self._exposure_time: float = Image.UNDEF_EXP_TIME

    def clone(self, keep_ref_to_data=False):
        """
        Clone an image
        :param keep_ref_to_data: don't copy numpy data. This allows light image clone
        :type keep_ref_to_data: bool
        :return: an image with global copied data
        :rtype: Image
        """
        new_image_data = self.data if keep_ref_to_data else self.data.copy()
        new_image = Image(new_image_data)
        new_image.bayer_pattern = self.bayer_pattern
        new_image.origin = self.origin
        new_image.destination = self.destination
        new_image.ticket = self.ticket
        new_image.exposure_time = self.exposure_time
        return new_image

    @property
    def exposure_time(self):
        return self._exposure_time

    @exposure_time.setter
    def exposure_time(self, value):
        self._exposure_time = value

    @property
    def destination(self):
        """
        Retrieves image destination
        :return: the destination
        :rtype: str
        """
        return self._destination

    @destination.setter
    def destination(self, destination):
        """
        Sets image destination
        :param destination: the image destination
        :type destination: str
        """
        self._destination = destination

    @property
    def ticket(self):
        """
        Retrieves image ticket
        :return: the ticket
        :rtype: str
        """
        return self._ticket

    @ticket.setter
    def ticket(self, ticket):
        """
        Sets image ticket
        :param ticket: the image ticket
        :type ticket: str
        """
        self._ticket = ticket

    @property
    def data(self):
        """
        Retrieves image data
        :return: image data
        :rtype: numpy.ndarray
        """
        return self._data

    @data.setter
    def data(self, data):
        self._data = data

    @property
    def origin(self):
        """
        retrieves info on image origin.
        If Image has been read from a disk file, origin contains the file path
        :return: origin representation
        :rtype: str
        """
        return self._origin

    @origin.setter
    def origin(self, origin):
        self._origin = origin

    @property
    def bayer_pattern(self):
        """
        Retrieves the bayer pattern the image was shot with, if applicable.
        :return: the bayer pattern or None
        :rtype: str
        """
        return self._bayer_pattern

    @property
    def dimensions(self):
        """
        Retrieves image dimensions as a tuple.
        This is basically the underlying array's shape tuple, minus the color axis if image is color
        :return: the image dimensions
        :rtype: tuple
        """
        if self._data.ndim == 2:
            return self._data.shape

        dimensions = list(self.data.shape)
        dimensions.remove(min(dimensions))
        return dimensions

    @property
    def width(self):
        """
        Retrieves image width
        :return: image width in pixels
        :rtype: int
        """
        return max(self.dimensions)

    @property
    def height(self):
        """
        Retrieves image height
        :return: image height in pixels
        :rtype: int
        """
        return min(self.dimensions)

    @bayer_pattern.setter
    def bayer_pattern(self, bayer_pattern):
        self._bayer_pattern = bayer_pattern

    def needs_debayering(self):
        """
        Tells if image needs debayering
        :return: True if a bayer pattern is known and data does not have 3 dimensions
        """
        return self._bayer_pattern != "" and self.data.ndim < 3

    def is_color(self):
        """
        Tells if the image has color information
        image has color information if its data array has more than 2 dimensions
        :return: True if the image has color information, False otherwise
        :rtype: bool
        """
        return self._data.ndim > 2

    def is_bw(self):
        """
        Tells if image is black and white
        :return: True if no color info is stored in data array, False otherwise
        :rtype: bool
        """
        return self._data.ndim == 2 and self._bayer_pattern == ""

    def is_same_shape_as(self, other):
        """
        Is this image's shape equal to another's ?
        :param other: other image to compare shape with
        :type other: Image
        :return: True if shapes are equal, False otherwise
        :rtype: bool
        """
        return self._data.shape == other.data.shape

    def set_color_axis_as(self, wanted_axis):
        """
        Reorganise internal data array so color information is on a specified axis
        :param wanted_axis: The 0-based number of axis we want color info to be
        Image data is modified in place
        """

        if self._data.ndim > 2:

            # find what axis are the colors on.
            # axis 0-based index is the index of the smallest data.shape item
            shape = self._data.shape
            color_axis = shape.index(min(shape))

            if color_axis != wanted_axis:
                self._data = numpy.moveaxis(self._data, color_axis, wanted_axis)

    def __repr__(self):
        representation = (f'{self.__class__.__name__}('
                          f'ID={self.__hash__()}, '
                          f'Color={self.is_color()}, '
                          f'Exp. t={self.exposure_time}, '
                          f'Needs Debayer={self.needs_debayering()}, '
                          f'Bayer Pattern={self.bayer_pattern}, '
                          f'Width={self.width}, '
                          f'Height={self.height}, '
                          f'Data shape={self._data.shape}, '
                          f'Data type={self._data.dtype.name}, '
                          f'Origin={self.origin}, '
                          f'Destination={self.destination}')

        return representation


#___________________________________________________________________________________________________________________________
# processing (align and stack)
#___________________________________________________________________________________________________________________________
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
        image.data = numpy.where(image.data / means > _HOT_PIXEL_RATIO, means, image.data)
    else:
        print("Hot Pixel Remover cannot work on debayered color images.")




def apply_transformation( image: Image, transformation: SimilarityTransform, _last_stacking_result: Image):

    if image.is_color():
            results_dict = dict()

            for channel in range(3):
                apply_single_channel_transformation(image,
                                                    _last_stacking_result,
                                                    transformation,
                                                    results_dict,
                                                    channel)
            for channel, data in results_dict.items():
                image.data[channel] = data

    else:
        result_dict = dict()

        apply_single_channel_transformation(
            image,
            _last_stacking_result,
            transformation,
            result_dict
        )

        image.data = result_dict[0]
    #numpy.float32(aa.apply_transform(transformation, image, _last_stacking_result))

def apply_single_channel_transformation(image, reference, transformation, results_dict, channel=None):
    """
    apply a transformation on a specific channel (RGB) of a color image, or whole data of a b&w image.
    :param image: the image to apply transformation to
    :type image: Image
    :param reference: the align reference image
    :type reference: Image
    :param transformation: the transformation to apply
    :type transformation: skimage.transform._geometric.SimilarityTransform
    :param results_dict: the dict into which transformation result is to be stored. dict key is the channel number
            for a color image, or 0 for a b&w image
    :type results_dict: dict
    :param channel: the 0 indexed number of the color channel to process (0=red, 1=green, 2=blue)
    :type channel: int
    """

    if channel is not None:
        target_index = channel
        source_data = image.data[channel]
        reference_data = reference.data[channel]
    else:
        target_index = 0
        source_data = image.data
        reference_data = reference.data
    

    aligned = aa.apply_transform(transformation, source_data, reference_data)[0]
    results_dict[target_index] = numpy.float32(aligned)



def find_transformation( image: Image, align_reference : Image):

   # for ratio in ratios:
    top, bottom, left, right = get_image_subset_boundaries(1.,align_reference)
        # pick green channel if image has color
    if image.is_color():
        new_subset = image.data[1][top:bottom, left:right]
        ref_subset = align_reference.data[1][top:bottom, left:right]
    else:
        new_subset = image.data[top:bottom, left:right]
        ref_subset = align_reference.data[top:bottom, left:right]

    try:
        transformation, matches = aa.find_transform(new_subset, ref_subset)
        matches_count = len(matches[0])
        if matches_count < 25:
            print('error not enough stars')
        return transformation

    # pylint: disable=W0703
    except Exception as alignment_error:
        # we have no choice but catching Exception, here. That's what AstroAlign raises in some cases
        # this will catch MaxIterError as well...
        print('alignement error')
        return None

            
def stack_image(image: Image, stack : Image, num : int, stacking_method : int = 0):
        """
        Compute stacking according to user defined stacking mode
        the image data is modified in place by this function
        :param image: the image to be stacked
        :type image: Image
        """

        if stacking_method == 0:
            stack.data = image.data + stack.data
        elif stacking_method == 1:
            stack.data = (num * stack.data + image.data) / (1 + num)

def get_image_subset_boundaries(ratio: float, last_stacking_result):
    """
    Retrieves a tuple of 4 int values representing the limits of a centered box (a.k.a. subset) as big as
    ratio * stored stacking result's size
    :param ratio: size ratio of subset vs stacking result
    :type ratio: float
    :return: a tuple of 4 int for top, bottom, left, right
    :rtype: tuple
    """

    width = last_stacking_result.width
    height =last_stacking_result.height

    horizontal_margin = int((width - (width * ratio)) / 2)
    vertical_margin = int((height - (height * ratio)) / 2)

    left = 0 + horizontal_margin
    right = width - horizontal_margin - 1
    top = 0 + vertical_margin
    bottom = height - vertical_margin - 1

    return top, bottom, left, right

#https://github.com/gehelem/als/blob/release/0.7/src/als/processing.py
def debayer(image: Image):


    preferred_bayer_pattern = "AUTO"

    if preferred_bayer_pattern == "AUTO" and not image.needs_debayering():
        print("no debayer")

    cv2_debayer_dict = {

        "BG": cv2.COLOR_BAYER_BG2RGB,
        "GB": cv2.COLOR_BAYER_GB2RGB,
        "RG": cv2.COLOR_BAYER_RG2RGB,
        "GR": cv2.COLOR_BAYER_GR2RGB
    }

    if preferred_bayer_pattern != 'AUTO':
        bayer_pattern = preferred_bayer_pattern

        if image.needs_debayering() and bayer_pattern != image.bayer_pattern:
           print("The bayer pattern defined in your preferences differs from the one present in current image.")


    else:
        bayer_pattern = image.bayer_pattern

    cv_debay = bayer_pattern[3] + bayer_pattern[2]

    try:
        debayered_data = cv2.cvtColor(image.data, cv2_debayer_dict[cv_debay])
    except KeyError:
        print(f"unsupported bayer pattern : {bayer_pattern}")
    except cv2.error as error:
        raise print(f"Debayering error : {str(error)}")

    image.data = debayered_data

def color_balance(image : Image, red : float, green : float, blue: float):
    # red, green, blue : float 0-2
    image.data[0] = image.data[0] * red
    image.data[1] = image.data[1] * green
    image.data[2] = image.data[2] * blue
    image.data = numpy.clip(image.data, 0, 2**16 - 1)

def levels(image : Image, black: float, midtones: float, white: float):
    # pylint: disable=R0914

    # mids : 0-2
    # black : int 0-max(int)
    # white : int 0-max(int)
    
    image.data = _16_BITS_MAX_VALUE * image.data ** (1 / midtones) / _16_BITS_MAX_VALUE ** (1 / midtones)

    # black / white levels
    image.data = numpy.clip(image.data, black, white)

    # final interpolation if we touched the image

    image.data = numpy.float32(numpy.interp(image.data,
                                            (image.data.min(), image.data.max()),
                                            (0, _16_BITS_MAX_VALUE)))


def open_fits(filename):
    with fits.open(filename) as fit:
        # pylint: disable=E1101
        data = fit[0].data
        header = fit[0].header

    image = Image(data)
    if 'BAYERPAT' in header:
        image.bayer_pattern = header['BAYERPAT']

    if 'EXPTIME' in header:
        image.exposure_time = header['EXPTIME']
    print(image)

    hot_pixel_remover(image)
    debayer(image)
    if image.is_color():
            image.set_color_axis_as(0)
    
    image.data = numpy.float32((image.data))
    print(image)
    return image

def normalize(image):
    if image.is_color():
        image.set_color_axis_as(2)
        image.data = numpy.uint16(numpy.clip(image.data, 0, _16_BITS_MAX_VALUE))

def save_jpeg(image, filename):

    
    
    image.data = (image.data / (((2 ** 16) - 1) / ((2 ** 8) - 1))).astype('uint8')
    cv2_color_conversion_flag = cv2.COLOR_RGB2BGR if image.is_color() else cv2.COLOR_GRAY2BGR

    return cv2.imwrite(filename,
                        cv2.cvtColor(image.data, cv2_color_conversion_flag),
                        [int(cv2.IMWRITE_JPEG_QUALITY), 100]), ''

def stretch(image : Image, strength : float):
    # strength float : 0-1
    image.data = numpy.interp(image.data,
                                   (image.data.min(), image.data.max()),
                                   (0, _16_BITS_MAX_VALUE))
    if image.is_color():
        for channel in range(3):
            image.data[channel] = Stretch(target_bkg=strength).stretch(image.data[channel])
        else:
            image.data = Stretch(target_bkg=strength).stretch(image.data)
    image.data *= _16_BITS_MAX_VALUE




#___________________________________________________________________________________________________________________________
# gradiant remover
#___________________________________________________________________________________________________________________________


__all__ = ["gridBackgroundRemove", "_fitBg"]
def max_type(dtype):
    '''
    max_type(dtype(numpy.dtype))
    Get the maximum value of a given dtype. Note that for numpy.float32 based
    images, the maximum value is 1.0, not max of float32.
    dtype: numpy.dtype
    '''
    if dtype == numpy.float32 or dtype == numpy.float64:
        return 1.0
    else:
        return numpy.iinfo(dtype).max
    

def convertTo(img_data, dtype):
    '''
    convertTo(img_data(2D or 3D numpy.ndarray)dtype(numpy.dtype))
    Convert image data to a given dtype. Since OpenCV can only handle uint8
    or uint16 data, it is necessary to apply if the input data is directly
    from DSS.
    img_data: 2D or 3D numpy.ndarray, input image data
    dtype: numpy.dtype, dtype to cast to. Usually numpy.uint8 or
           numpy.uint16. Seldomly, it can be numpy.float32.
    '''
    if dtype != img_data.dtype:
        tmp = numpy.float64(img_data) / max_type(img_data.dtype) * max_type(dtype)
        numpy.clip(tmp, 0.0, max_type(dtype), out=tmp)
        tmp = tmp.astype(dtype)
    else:
        tmp = img_data
    return tmp


def gridBackgroundRemove(img_data, gSize=64, doMask=None, skipThres=0.75,
                         infillLength=7, smoothSigma=None):
    '''
    Remove background by fitting a linear model in gSize * gSize. External
    mask is provided with doMask, where max_type(dtype) is fitted, and other
    values are ignored.
    Parameters
    ----------
    img_data: 2D or 3D numpy.ndarray
        The inumpyut image data
    gSize: int, default 64
        The size of grid in pixels
    doMask: 2D nummpy.ndarray, default None
        Mask to fit. Will automatically convert to numpy.float32 for fitting
        purposes.
    skipThres: float, default 0.75
        If more than skipThres (ratio) of pixels are masked, skip fitting the
        entire gSize * gSize area.
    infillLength: int, default 7
        Pixel to consider when applying inumpyaint to large masks.
    smoothSigma: float, default None
        Sigma of Gaussian blur for smoothing. If None, skip smoothing. However,
        it is recommended to apply smoothing due to edge effect near the edge
        of each grid.
    Returns
    -------
    img_no_bg: numpy.ndarray, same shape as inumpyut
        The image data with background removed
    Raises
    ------
    None
    '''
    img_mask = None
    if doMask is None:
        img_mask = numpy.ones(img_data.shape[:-1], dtype=numpy.float32)
    else:
        img_mask = convertTo(doMask, numpy.float32)
    img_bg = numpy.empty(img_data.shape, dtype=numpy.float32)
    img_bg_mask = numpy.zeros(img_data.shape[0: 2], dtype=numpy.uint8)
    x_grid_num = int(numpy.ceil(img_data.shape[0] / gSize))
    y_grid_num = int(numpy.ceil(img_data.shape[1] / gSize))
    for i in range(x_grid_num):
        for j in range(y_grid_num):
            x_0, x_1 = i * gSize, (i + 1) * gSize
            y_0, y_1 = j * gSize, (j + 1) * gSize
            fit_data = img_data[x_0: x_1, y_0: y_1]
            fit_mask = img_mask[x_0: x_1, y_0: y_1]
            if numpy.count_nonzero(fit_mask) < skipThres * fit_mask.size:
                img_bg[x_0: x_1, y_0: y_1] = 1.0
                img_bg_mask[x_0: x_1, y_0: y_1] = 255
            else:
                img_bg[x_0: x_1, y_0: y_1] = _fitBg(fit_data, fit_mask)
    # cv2.inumpyaint to fill blank areas
    if img_data.ndim == 3:
        for i in range(img_data.shape[-1]):
            img_bg[:, :, i] = cv2.inpaint(img_bg[:, :, i], img_bg_mask,
                                          infillLength, cv2.INPAINT_NS)
    else:
        img_bg = cv2.inpaint(img_bg, img_bg_mask, infillLength, cv2.INPAINT_NS)
    # Smooth the background
    if smoothSigma is not None:
        img_bg = cv2.GaussianBlur(img_bg, (0, 0), smoothSigma)
    img_no_bg = img_data - img_bg
    return img_no_bg

def _fitBg(fit_data, fit_mask):
    pos_x = numpy.linspace(0.0, fit_data.shape[0] - 1, fit_data.shape[0])
    pos_y = numpy.linspace(0.0, fit_data.shape[1] - 1, fit_data.shape[1])
    X, Y = numpy.meshgrid(pos_x, pos_y)
    pos = numpy.array([X.ravel(), Y.ravel()]).T
    one_col = numpy.ones((pos.shape[0], 1))
    pos = numpy.hstack((pos, one_col))
    yy = fit_data.reshape(fit_data.shape[0] * fit_data.shape[1], -1)
    w = fit_mask.reshape(-1, 1)
    # a = pos.T * w * pos
    # Since w is always diagonal, it can be simplified
    a = numpy.matmul(pos.T, w * pos)
    # b = pos.T * w * yy
    # Since w is always diagonal, it can be simplified
    b = numpy.matmul(pos.T, w * yy)
    # Linear lsq: ax = b
    fit_res = numpy.linalg.lstsq(a, b, rcond=None)
    # bg = pos * x
    bg = numpy.matmul(pos, fit_res[0])
    return bg.reshape(fit_data.shape)


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
#___________________________________________________________________________________________________________________________
# test
#___________________________________________________________________________________________________________________________
import os


def test_all():
    path = './image_test/'
    dirs = os.listdir( path )
    fits_list = []
    for file in dirs:
        filename, file_extension = os.path.splitext(file)
        if file_extension=='.fits':
            fits_list.append(path+file)
    i=1
    ref = open_fits(fits_list[0])
    stacked = ref.clone()

    while i<len(fits_list):
        print("traiting image %s" % (fits_list[i]))
        im2 = open_fits(fits_list[i])

        transformation = find_transformation(im2, ref)
        if transformation==None:
            print("... No alignment point, skipping image ...")
        else:
            apply_transformation(im2, transformation, ref)
            stack_image(im2,stacked,i, 1)
        i+=1

    levels(stacked, 1000, 1,65535)
    stretch(stacked, 0.18)
    color_balance(stacked, 1, 1, 1)
    #sharpen(stacked)

    copy = stacked.clone()
    stacked.data = denoise_tv_chambolle(stacked.data, weight=0.1, channel_axis=0)
    normalize(stacked)
    save_jpeg(stacked,'result denoise - chambolle1.jpg')

    #stacked = copy.clone()
    #stacked.data = denoise_bilateral(stacked.data, sigma_color=0.05, sigma_spatial=15, channel_axis=-1)
    #save_jpeg(stacked,'result denoise - bilateral1.jpg')

    #stacked = copy.clone()
    #stacked.data = denoise_wavelet(stacked.data, channel_axis=-1, rescale_sigma=True)
    #save_jpeg(stacked,'result denoise - wavelet1.jpg')

    stacked = copy.clone()
    stacked.data = denoise_tv_chambolle(stacked.data, weight=1000, channel_axis=0)
    normalize(stacked)
    save_jpeg(stacked,'result denoise - chambolle2.jpg')

    stacked = copy.clone()
    stacked.data = gridBackgroundRemove(stacked.data)
    normalize(stacked)
    save_jpeg(stacked,'background.jpg')

    stacked = copy.clone()
    normalize(stacked)
    stacked.data = gammaCorrection(stacked.data,1.1)
    normalize(stacked)
    save_jpeg(stacked,'gamma.jpg')
    

def test():
    img = ImagePIL.open('result - no sharpen.jpg')
    
    image = Image(numpy.asarray(img)).clone()
    print("Rolling ball")
    for channel in range(3):
        background = rolling_ball(image.data[channel])
        image.data[channel] = background
    print("End rolling ball")
    cv2.imwrite('test.jpg',
                        cv2.cvtColor(image.data, cv2.COLOR_RGB2BGR),
                        [int(cv2.IMWRITE_JPEG_QUALITY), 100]), ''

test_all()