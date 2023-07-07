from ..models.image import Image
import cv2
import numpy
from ..models.constants import I16_BITS_MAX_VALUE
from astropy.io import fits
import io
from ..imageprocessor.filters import stretch, hot_pixel_remover


def debayer(image: Image):

    if image==None:
        return
    preferred_bayer_pattern = "AUTO"

    if preferred_bayer_pattern == "AUTO" and not image.needs_debayering():
        return

    print("debayer")
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
        print(f"Debayering error : {str(error)}")

    image.data = debayered_data



def open_fits(filename):
    try:
        with fits.open(filename) as fit:
            # pylint: disable=E1101
            data = fit[0].data
            header = fit[0].header

        image = Image(data)
        if 'BAYERPAT' in header:
            image.bayer_pattern = header['BAYERPAT']

        if 'EXPTIME' in header:
            image.exposure_time = header['EXPTIME']

        #hot_pixel_remover(image)
        #debayer(image)
        #if image.is_color():
        #        image.set_color_axis_as(0)
        
        return image
    except Exception as e:
        print(e)



def adapt(image):
    if image.is_color():
        image.set_color_axis_as(0)
    image.data = numpy.float32((image.data))

def normalize(image):
    if image.is_color():
        image.set_color_axis_as(2)
    image.data = numpy.uint16(numpy.clip(image.data, 0, I16_BITS_MAX_VALUE))
    return image

def reduce(image, size):
    new_width = int(image.shape[1] * (size))
    new_height = int(image.shape[0] * (size))
    resized_image = numpy.resize(image, (new_height, new_width))

    return resized_image

def save_jpeg(image, filename):
    
    image.data = (image.data / (((2 ** 16) - 1) / ((2 ** 8) - 1))).astype('uint8')
    cv2_color_conversion_flag = cv2.COLOR_RGB2BGR if image.is_color() else cv2.COLOR_GRAY2BGR

    return cv2.imwrite(filename,
                        cv2.cvtColor(image.data, cv2_color_conversion_flag),
                        [int(cv2.IMWRITE_JPEG_QUALITY), 100]), ''

def save_to_bytes(image, format, size=1):

    image.data = (image.data / (((2 ** 16) - 1) / ((2 ** 8) - 1))).astype('uint8')
    cv2_color_conversion_flag = cv2.COLOR_RGB2BGR if image.is_color() else cv2.COLOR_GRAY2BGR
    if size <1:
        width = int(image.data.shape[1] * size)
        height = int(image.data.shape[0] * size)
        dim = (width, height)
        image.data = cv2.resize(image.data, dim, interpolation = cv2.INTER_AREA)

    is_success, buffer = cv2.imencode("."+format,cv2.cvtColor(image.data, cv2_color_conversion_flag))
   
    io_buf = io.BytesIO(buffer)
    return io_buf

def open_process_fits(filename):
    image = open_fits(filename)
    hot_pixel_remover(image)
    debayer(image)
    adapt(image)
    return image