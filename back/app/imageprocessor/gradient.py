import numpy
import cv2


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