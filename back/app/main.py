from fastapi import FastAPI
from fastapi.responses import RedirectResponse
from fastapi.middleware.cors import CORSMiddleware
import logging
from fastapi.staticfiles import StaticFiles



from .router import (
    planning,
    platesolver,
    telescope,
)   

level = logging.DEBUG
for handler in logging.root.handlers[:]:
    logging.root.removeHandler(handler) 
logging.basicConfig(filename = '/tmp/easyastro.log', filemode='w', level=level)
logger = logging.getLogger(__name__)
logger.info('STARTING')

app = FastAPI()
origins = [
    "*",
    "http://localhost:5173",
    "http://localhost:8000",
    "http://localhost:3000",
]   

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def redirect():
    response = RedirectResponse(url='/static/index.html')
    return response


app.include_router(planning.router, prefix='/planning')
app.include_router(platesolver.router, prefix='/platesolver')
app.include_router(telescope.router, prefix='/telescope')
app.mount("/static", StaticFiles(directory="static"), name="static")

#from .lib import fitsutils

#img_bytes = fitsutils.fits_to_png('./test/M_51_3_Light_001.fits')

#open('./test/M_51_3_Light_001.jpg', 'wb').write(img_bytes)

#from .lib import fitsutils
#fitsutils.fits_to_png('../../debug/platesolve1.fits')

"""

from .imageprocessor.utils import open_fits, debayer, adapt, save_to_bytes, normalize
from .imageprocessor.filters import hot_pixel_remover
from .models.image import Image
from .lib.fitsutils import sky_median_sig_clip
image = open_fits('../../debug/platesolve2.fits')
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
"""
"""
from .imageprocessor.utils import open_fits, debayer, adapt, save_to_bytes, normalize
from .imageprocessor.filters import hot_pixel_remover
from .models.image import Image
from .lib.fitsutils import sky_median_sig_clip

image = open_fits('./test/image_test/M_97_Light_002.fits')
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
"""