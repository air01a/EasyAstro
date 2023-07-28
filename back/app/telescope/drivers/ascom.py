import time
import threading
from queue import SimpleQueue
from app.dependencies import config
import logging
import win32com.client
from astropy.io import fits
import numpy as np
# import  pyfits

class ASCOMPilot():
    SLEW_MODE_SLEW = 0
    SLEW_MODE_TRACK = 1
    SLEW_MODE_SYNC = 2


    def __init__(self, communication_callback  ):
        self.communication_callback = communication_callback
        self.moving = False
        self.shooting = False
        self.lock = threading.Lock()
        self.connect()
        self.telescope_connect()
        self.ccd_connect()


    def connect(self):
        
        return 0

    def telescope_connect(self):
        #engine = win32com.client.Dispatch('ASCOM.Utilities.Chooser')
        #engine.DeviceType = 'Telescope'
        #driver = engine.Choose("ASCOM.Simulator.Telescope")
        #self.telescope = win32com.client.Dispatch(driver)
        self.telescope = win32com.client.Dispatch(config.CONFIG['DEVICE']['TELESCOPE'])
        self.telescope.Connected = True
        self.telescope.Tracking = True

        return 
    
    def sync(self, ra, dec):
        self.telescope.SyncToCoordinates(ra,dec)
        


    def get_current_coordinates(self):
        return (self.telescope.RightAscension, self.telescope.Declination)
        

    def move_short(self, delta_ra, delta_dec):
        (ra, dec) = self.get_current_coordinates()
        self.goto(ra+delta_ra, dec + delta_dec)
        return 
        

    def goto(self, ra, dec):
        self.communication_callback(1,"Scope Moving %f %f" % (ra, dec),0)
        self.telescope.SlewToCoordinates(ra,dec) 
        self.communication_callback(1,"MOVING IS FINISHED",0)
        return

    def ccd_connect(self):
        driver = config.CONFIG['DEVICE']['CCD']
        self.camera = win32com.client.Dispatch(driver)
        self.camera.connected = True
        print(self.camera.CameraXSize, self.camera.CameraYSize)
        return 

    def take_picture(self, filename : str, exposure : float, gain : int, image_type : int = 0, binning : int = 0):
        
        openshutter = True
        self.camera.StartExposure(exposure,openshutter)
        while not self.camera.ImageReady:
            time.sleep(0.1)
        image = self.camera.ImageArray
        rotated_image = np.rot90(image, k=1)
        
        hdu = fits.PrimaryHDU(rotated_image.astype(np.uint16))
        header = hdu.header

        # Ajoutez ou modifiez les informations d'orientation dans l'en-tête
        header['ORIENTAT'] = 0.0  # Spécifiez l'orientation souhaitée (en degrés)

        hdul = fits.HDUList([hdu])

        # Écrivez les données dans un fichier FITS
        hdul.writeto(filename, overwrite=True)
        #hdu.header['SIMPLE']='T'
        #hdu.header['BITPIX']=16

        #hdu.writeto(filename, overwrite=True)
        #pyfits.writeto(filename, image)
        return