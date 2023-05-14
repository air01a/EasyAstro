
from .imageprocessor.utils import open_fits, debayer, adapt, save_to_bytes, normalize
from .imageprocessor.filters import hot_pixel_remover
from .models.image import Image
from .lib.fitsutils import sky_median_sig_clip

image = open_fits('../../../debug/platesolve1.fits')
#image = open_fits('/tmp/platesolve.fits')
print(image)
hot_pixel_remover(image)
print(image)
debayer(image)
print(image)
adapt(image)

(image.data,iterations) = sky_median_sig_clip(image.data,0.1,0.1,10)
normalize(image)
data = save_to_bytes(image,'jpg').getvalue()

open('filename.jpg', 'wb').write(data)
