import numpy
from astropy.io import fits
import cv2
#ImageFile.LOAD_TRUNCATED_IMAGES = True
from skimage.transform import SimilarityTransform

import astroalign as aa
from rawpy import imread

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
                print(channel)
                print(data)
                image.data[channel] = data[0]

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
        print("not none")
        target_index = channel
        source_data = image.data[channel]
        reference_data = reference.data[channel]
    else:
        target_index = 0
        source_data = image.data
        reference_data = reference.data
    
    results_dict[target_index] = numpy.float32(aa.apply_transform(transformation, source_data, reference_data))



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
        print("Match count %i", matches_count)
        if matches_count < 5:
            print('error not enough stars')
        return transformation

    # pylint: disable=W0703
    except Exception as alignment_error:
        # we have no choice but catching Exception, here. That's what AstroAlign raises in some cases
        # this will catch MaxIterError as well...
        print('alignement error')

            
def stack_image(image: Image, old : Image, num : int, stacking_method : int = 0):
        """
        Compute stacking according to user defined stacking mode
        the image data is modified in place by this function
        :param image: the image to be stacked
        :type image: Image
        """

        if stacking_method == 0:
            old.data = image.data + old.data
        elif stacking_method == 1:
            old.data = (num * old.data + image.data) / (1 + num)

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


    preferred_bayer_pattern = "RGGB"

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
    image.data[0] = image.data[0] * red
    image.data[1] = image.data[1] * green
    image.data[2] = image.data[2] * blue
    image.data = numpy.clip(image.data, 0, 2**16 - 1)

def levels(image : Image, black: float, midtones: float, white: float):
    # pylint: disable=R0914

    # mids : 0-2
    # black : int 0-max(int)
    # white : int 0-max(int)
    _16_BITS_MAX_VALUE = 2**16 - 1
    image.data = _16_BITS_MAX_VALUE * image.data ** (1 / midtones) / _16_BITS_MAX_VALUE ** (1 / midtones)

    # black / white levels
    image.data = numpy.clip(image.data, black, white)

    # final interpolation if we touched the image

    image.data = numpy.float32(numpy.interp(image.data,
                                            (image.data.min(), image.data.max()),
                                            (0, _16_BITS_MAX_VALUE)))

    return image

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

    debayer(image)
    if image.is_color():
            image.set_color_axis_as(0)
    
    image.data = numpy.float32((image.data))
    return image

def save_jpeg(image, filename):
    if image.is_color():
        image.set_color_axis_as(2)
        image.data = numpy.uint16(numpy.clip(image.data, 0, 2 ** 16 - 1))
    
    
    image.data = (image.data / (((2 ** 16) - 1) / ((2 ** 8) - 1))).astype('uint8')
    cv2_color_conversion_flag = cv2.COLOR_RGB2BGR if image.is_color() else cv2.COLOR_GRAY2BGR

    return cv2.imwrite(filename,
                        cv2.cvtColor(image.data, cv2_color_conversion_flag),
                        [int(cv2.IMWRITE_JPEG_QUALITY), 100]), ''


import os

path = './image_test/'
dirs = os.listdir( path )
fits_list = []
for file in dirs:
    filename, file_extension = os.path.splitext(file)
    if file_extension=='.fits':
        fits_list.append(path+file)
print(fits_list)
i=0
ref = open_fits(fits_list[0])
stacked = ref.clone()

while i<len(fits_list):
    im2 = open_fits(fits_list[i])

    transformation = find_transformation(im2, ref)
    apply_transformation(im2, transformation, ref)
    stack_image(im2,stacked,i, 0)
    i+=1
levels(stacked, 0, 1,65536)
save_jpeg(stacked,'result.jpg')

#registered, footprint = aa.register(im1, im2  , min_area=9)
#transformation, matches = aa.find_transform(im2, im1)
#matches_count = len(matches[0])

#registered = numpy.float32(aa.apply_transform(transformation, im2, im1))
#registered = numpy.float32(registered)

#finaldata = im1.data + registered.data
#final = Image(finaldata)
#save_jpeg(final,'test.jpg')

#im1.save('res1.jpg', format='JPEG')
#im2.save('res2.jpg', format='JPEG')

#final += numpy.array(registered)


#registered_image = Image.fromarray(final.astype("uint8"))

#registered_image.save('resultat', format='JPEG')