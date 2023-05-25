import math
from io import BytesIO
from PIL import Image, ImageFile
from astropy.io import fits
import numpy
import astropy.io.fits as pyfits
import cv2
#ImageFile.LOAD_TRUNCATED_IMAGES = True

def sky_median_sig_clip(input_arr, sig_fract, percent_fract, max_iter=100):
	"""Estimating sky value for a given number of iterations
	@type input_arr: numpy array
	@param input_arr: image data array
	@type sig_fract: float
	@param sig_fract: fraction of sigma clipping
	@type percent_fract: float
	@param percent_fract: convergence fraction
	@type max_iter: max. of iterations
	@rtype: tuple
	@return: (sky value, number of iteration)
	"""
	work_arr = numpy.ravel(input_arr)
	old_sky = numpy.median(work_arr)
	sig = work_arr.std()
	upper_limit = old_sky + sig_fract * sig
	lower_limit = old_sky - sig_fract * sig
	indices = numpy.where((work_arr < upper_limit) & (work_arr > lower_limit))
	work_arr = work_arr[indices]
	new_sky = numpy.median(work_arr)
	iteration = 0
	while ((math.fabs(old_sky - new_sky)/new_sky) > percent_fract) and (iteration < max_iter) :
		iteration += 1
		old_sky = new_sky
		sig = work_arr.std()
		upper_limit = old_sky + sig_fract * sig
		lower_limit = old_sky - sig_fract * sig
		indices = numpy.where((work_arr < upper_limit) & (work_arr > lower_limit))
		work_arr = work_arr[indices]
		new_sky = numpy.median(work_arr)
	return (new_sky, iteration)


def sky_mean_sig_clip(input_arr, sig_fract, percent_fract, max_iter=100):
	"""Estimating sky value for a given number of iterations
	@type input_arr: numpy array
	@param input_arr: image data array
	@type sig_fract: float
	@param sig_fract: fraction of sigma clipping
	@type percent_fract: float
	@param percent_fract: convergence fraction
	@type max_iter: max. of iterations
	@rtype: tuple
	@return: (sky value, number of iteration)
	"""
	work_arr = numpy.ravel(input_arr)
	old_sky = numpy.mean(work_arr)
	sig = work_arr.std()
	upper_limit = old_sky + sig_fract * sig
	lower_limit = old_sky - sig_fract * sig
	indices = numpy.where((work_arr < upper_limit) & (work_arr > lower_limit))
	work_arr = work_arr[indices]
	new_sky = numpy.mean(work_arr)
	iteration = 0
	while ((math.fabs(old_sky - new_sky)/new_sky) > percent_fract) and (iteration < max_iter) :
		iteration += 1
		old_sky = new_sky
		sig = work_arr.std()
		upper_limit = old_sky + sig_fract * sig
		lower_limit = old_sky - sig_fract * sig
		indices = numpy.where((work_arr < upper_limit) & (work_arr > lower_limit))
		work_arr = work_arr[indices]
		new_sky = numpy.mean(work_arr)
	return (new_sky, iteration)



def linear(inputArray, scale_min=None, scale_max=None):
	"""Performs linear scaling of the input numpy array.
	@type inputArray: numpy array
	@param inputArray: image data array
	@type scale_min: float
	@param scale_min: minimum data value
	@type scale_max: float
	@param scale_max: maximum data value
	@rtype: numpy array
	@return: image data array
	
	"""		
	print("img_scale : linear")
	imageData=numpy.array(inputArray, copy=True)
	
	if scale_min == None:
		scale_min = imageData.min()
	if scale_max == None:
		scale_max = imageData.max()

	imageData = imageData.clip(min=scale_min, max=scale_max)
	imageData = (imageData -scale_min) / (scale_max - scale_min)
	indices = numpy.where(imageData < 0)
	imageData[indices] = 0.0
	indices = numpy.where(imageData > 1)
	imageData[indices] = 1.0
	
	return imageData


def sqrt(inputArray, scale_min=None, scale_max=None):
	"""Performs sqrt scaling of the input numpy array.
	@type inputArray: numpy array
	@param inputArray: image data array
	@type scale_min: float
	@param scale_min: minimum data value
	@type scale_max: float
	@param scale_max: maximum data value
	@rtype: numpy array
	@return: image data array
	
	"""		
    
	print("img_scale : sqrt")
	imageData=numpy.array(inputArray, copy=True)
	
	if scale_min == None:
		scale_min = imageData.min()
	if scale_max == None:
		scale_max = imageData.max()

	imageData = imageData.clip(min=scale_min, max=scale_max)
	imageData = imageData - scale_min
	indices = numpy.where(imageData < 0)
	imageData[indices] = 0.0
	imageData = numpy.sqrt(imageData)
	imageData = imageData / math.sqrt(scale_max - scale_min)
	
	return imageData


def log(inputArray, scale_min=None, scale_max=None):
	"""Performs log10 scaling of the input numpy array.
	@type inputArray: numpy array
	@param inputArray: image data array
	@type scale_min: float
	@param scale_min: minimum data value
	@type scale_max: float
	@param scale_max: maximum data value
	@rtype: numpy array
	@return: image data array
	
	"""		
    
	print("img_scale : log")
	imageData=numpy.array(inputArray, copy=True)
	
	if scale_min == None:
		scale_min = imageData.min()
	if scale_max == None:
		scale_max = imageData.max()
	factor = math.log10(scale_max - scale_min)
	indices0 = numpy.where(imageData < scale_min)
	indices1 = numpy.where((imageData >= scale_min) & (imageData <= scale_max))
	indices2 = numpy.where(imageData > scale_max)
	imageData[indices0] = 0.0
	imageData[indices2] = 1.0
	try :
		imageData[indices1] = numpy.log10(imageData[indices1])/factor
	except :
		print("Error on math.log10 for ",(imageData[i][j] - scale_min))

	return imageData


def asinh(inputArray, scale_min=None, scale_max=None, non_linear=2.0):
	"""Performs asinh scaling of the input numpy array.
	@type inputArray: numpy array
	@param inputArray: image data array
	@type scale_min: float
	@param scale_min: minimum data value
	@type scale_max: float
	@param scale_max: maximum data value
	@type non_linear: float
	@param non_linear: non-linearity factor
	@rtype: numpy array
	@return: image data array
	
	"""		
    
	print("img_scale : asinh")
	imageData=numpy.array(inputArray, copy=True)
	
	if scale_min == None:
		scale_min = imageData.min()
	if scale_max == None:
		scale_max = imageData.max()
	factor = numpy.arcsinh((scale_max - scale_min)/non_linear)
	indices0 = numpy.where(imageData < scale_min)
	indices1 = numpy.where((imageData >= scale_min) & (imageData <= scale_max))
	indices2 = numpy.where(imageData > scale_max)
	imageData[indices0] = 0.0
	imageData[indices2] = 1.0
	imageData[indices1] = numpy.arcsinh((imageData[indices1] - \
	scale_min)/non_linear)/factor

	return imageData

def fits_to_png3(filename):
    image_data = fits.getdata(filename)
    if len(image_data.shape) == 2:
        sum_image = image_data
    else:
        sum_image = image_data[0] - image_data[0]
        for single_image_data in image_data:
            sum_image += single_image_data  
    sum_image = sqrt(sum_image, scale_min=0, scale_max=numpy.amax(image_data))
    sum_image = sum_image * 200
    im = Image.fromarray(sum_image)
    if im.mode != 'RGB':
        im = im.convert('RGB')
    img_bytes = BytesIO()
    im.save(img_bytes, format='PNG')
    return img_bytes.getvalue()

def white_balance(img):
    stack = []
    for i in cv2.split(img):
        hist, bins = numpy.histogram(i, 256, (0, 256))
        # remove colors at each end of the histogram which are used by only by .05% 
        tmp = numpy.where(hist > hist.sum() * 0.0005)[0]
        i_min = tmp.min()
        i_max = tmp.max()
        # stretch history a bit
        tmp = (i.astype(numpy.int32) - i_min) / (i_max - i_min) * 255
        tmp = numpy.clip(tmp, 0, 255)
        stack.append(tmp.astype(numpy.uint8))
    return numpy.dstack(stack)


def fits_to_png2(filename):
	img_bytes = BytesIO()
	hdul = pyfits.open(filename)
	image_uint16=hdul[0].data
	image_int8 = cv2.normalize(image_uint16, None, 0, 255, cv2.NORM_MINMAX, dtype=cv2.CV_8U)
	image_rgb = cv2.cvtColor(image_int8, cv2.COLOR_BayerGB2RGB)
	is_success, img_bytes = cv2.imencode(".png",  white_balance(image_rgb))
	print("success"+str(is_success))
	return img_bytes.getvalue()
	#cv2.imwrite(img_bytes,)

from ..imageprocessor.utils import normalize, open_fits, debayer, save_to_bytes, adapt
from ..imageprocessor.filters import hot_pixel_remover, stretch, levels

def fits_to_png(filename):
    img = open_fits(filename)
    hot_pixel_remover(img)
    debayer(img)
    adapt(img)

    #levels(img, 1,1,65535)
    
    #stretch(img,0.18)
    normalize(img)
    img_bytes = save_to_bytes(img,'PNG')
    return img_bytes.getvalue()