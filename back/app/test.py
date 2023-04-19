
from .imageprocessor.utils import open_fits, debayer, adapt
from .imageprocessor.filters import hot_pixel_remover
from .models.image import Image
import pydantic

image = open_fits('./test/image_test/M_97_Light_001.fits')

hot_pixel_remover(image)
debayer(image)
adapt(image)
import sys
sys.exit(0)
