import PyIndi
import time
import asyncio
import threading
from queue import SimpleQueue
from ..platesolve import platesolver
from math import sqrt
from ..dependencies import error, config
import logging
from ..models.image import Image
import os
from ..imageprocessor.utils import open_fits, save_jpeg, adapt, normalize, debayer
from ..imageprocessor.filters import stretch, hot_pixel_remover
from ..imageprocessor.align import find_transformation, apply_transformation
from ..imageprocessor.stack import stack_image
from datetime import datetime

MAX_PLATESOLVE_ERROR=1
logger = logging.getLogger(__name__)


blobEvent = None
class IndiClient(PyIndi.BaseClient):
    def __init__(self):
        super(IndiClient, self).__init__()

    def updateProperty(self, prop):
        global blobEvent
        if prop.getType() == PyIndi.INDI_BLOB:
            blobEvent.set()


class IndiPilot():
    SLEW_MODE_SLEW = 0
    SLEW_MODE_TRACK = 1
    SLEW_MODE_SYNC = 2

    COORD_EOD = "EQUATORIAL_EOD_COORD"
    COORD_J2000 = "EQUATORIAL_COORD"
    TARGET_EOD = "TARGET_EOD_COORD"

    def __init__(self, queue_in : SimpleQueue, queue_out:SimpleQueue ):
        self.queue_in = queue_in
        self.queue_out = queue_out
        self.moving = False
        self.shooting = False
        self.lock = threading.Lock()


    def connect(self):
        # connect the server
        self.indiclient = IndiClient()
        self.indiclient.setServer("localhost", 7624)

        if not self.indiclient.connectServer():
            logger.error(
                "No indiserver running on "
                + self.indiclient.getHost()
                + ":"
                + str(self.indiclient.getPort())
            )
        return 0

    def telescope_connect(self):
        # connect the scope
        self.telescope = "Telescope Simulator"
        self.device_telescope = None
        self.telescope_connect = None

        # get the telescope device
        self.device_telescope = self.indiclient.getDevice(self.telescope)
        while not self.device_telescope:
            time.sleep(0.5)
            self.device_telescope = self.indiclient.getDevice(self.telescope)

        # wait CONNECTION property be defined for telescope
        self.telescope_connect = self.device_telescope.getSwitch("CONNECTION")
        while not self.telescope_connect:
            time.sleep(0.5)
            self.telescope_connect = self.device_telescope.getSwitch("CONNECTION")

        # if the telescope device is not connected, we do connect it
        if not self.device_telescope.isConnected():
            # Property vectors are mapped to iterable Python objects
            # Hence we can access each element of the vector using Python indexing
            # each element of the "CONNECTION" vector is a ISwitch
            self.telescope_connect.reset()
            self.telescope_connect[0].setState(PyIndi.ISS_ON)  # the "SYNC" switch
            self.indiclient.sendNewProperty(self.telescope_connect)  # send this new value to the device

    def sync(self, ra, dec):
        self.telescope_on_coord_set = self.device_telescope.getSwitch("ON_COORD_SET")
        while not self.telescope_on_coord_set:
            time.sleep(1)
            self.telescope_on_coord_set = self.device_telescope.getSwitch("ON_COORD_SET")
        self.telescope_on_coord_set.reset()
        self.telescope_on_coord_set[2].setState(PyIndi.ISS_ON)  # index 0-TRACK, 1-SLEW, 2-SYNC
        self.indiclient.sendNewProperty(self.telescope_on_coord_set)
        # We set the desired coordinates
        telescope_radec = self.device_telescope.getNumber(self.COORD_EOD)
        while not telescope_radec:
            time.sleep(0.5)
            telescope_radec = self.device_telescope.getNumber(self.COORD_EOD)
        telescope_radec[0].setValue(ra)
        telescope_radec[1].setValue(dec)
        self.indiclient.sendNewProperty(telescope_radec)    

    def get_current_coordinates(self):
        telescope_radec = self.device_telescope.getNumber("EQUATORIAL_EOD_COORD")
        while not telescope_radec:
            time.sleep(0.5)
            telescope_radec = self.device_telescope.getNumber("EQUATORIAL_EOD_COORD")
        return (telescope_radec[0].getValue(), telescope_radec[1].getValue())

    def goto(self, ra, dec):
        self.moving = True
        # Now let's make a goto to vega
        # Beware that ra/dec are in decimal hours/degrees
        #vega = {"ra": (279.23473479 * 24.0) / 360.0, "dec": +38.78368896}
        #vega = {"ra": (101.25 * 24.0) / 360.0, "dec": +16.7}
        # We want to set the ON_COORD_SET switch to engage tracking after goto
        # device.getSwitch is a helper to retrieve a property vector
        self.telescope_on_coord_set = self.device_telescope.getSwitch("ON_COORD_SET")
        while not self.telescope_on_coord_set:
            time.sleep(1)
            self.telescope_on_coord_set = self.device_telescope.getSwitch("ON_COORD_SET")
        # the order below is defined in the property vector, look at the standard Properties page
        # or enumerate them in the Python shell when you're developing your program
        self.telescope_on_coord_set.reset()
        self.telescope_on_coord_set[0].setState(PyIndi.ISS_ON)  # index 0-TRACK, 1-SLEW, 2-SYNC
        self.indiclient.sendNewProperty(self.telescope_on_coord_set)


        # We set the desired coordinates
        telescope_radec = self.device_telescope.getNumber("EQUATORIAL_EOD_COORD")
        while not telescope_radec:
            time.sleep(0.5)
            telescope_radec = self.device_telescope.getNumber("EQUATORIAL_EOD_COORD")
        telescope_radec[0].setValue(ra)
        telescope_radec[1].setValue(dec)
        self.indiclient.sendNewProperty(telescope_radec)

        # and wait for the scope has finished moving
        while telescope_radec.getState() == PyIndi.IPS_BUSY:
            self.queue_out.put("Scope Moving %f %f" % (telescope_radec[0].value, telescope_radec[1].value))
            time.sleep(2)
        self.moving = False
        self.queue_out.put('1.MOVING IS FINISHED')


    def take_picture(self, filename : str, exposure : int, gain : int, image_type : int = 0, binning : int = 0):
        
        global bobEvent
        self.lock.acquire()
        self.shooting = True

        # Let's take some pictures
        ccd = "CCD Simulator"
        device_ccd = self.indiclient.getDevice(ccd)
        while not (device_ccd):
            time.sleep(0.5)
            device_ccd = self.indiclient.getDevice(ccd)

        ccd_connect = device_ccd.getSwitch("CONNECTION")
        while not (ccd_connect):
            time.sleep(0.5)
            ccd_connect = device_ccd.getSwitch("CONNECTION")
        if not (device_ccd.isConnected()):
            ccd_connect.reset()
            ccd_connect[0].setState(PyIndi.ISS_ON)  # the "CONNECT" switch
            self.indiclient.sendNewProperty(ccd_connect)

        ccd_exposure = device_ccd.getNumber("CCD_EXPOSURE")
        while not (ccd_exposure):
            time.sleep(0.5)
            ccd_exposure = device_ccd.getNumber("CCD_EXPOSURE")

        # Ensure the CCD simulator snoops the telescope simulator
        # otherwise you may not have a picture of vega
        ccd_active_devices = device_ccd.getText("ACTIVE_DEVICES")
        while not (ccd_active_devices):
            time.sleep(0.5)
            ccd_active_devices = device_ccd.getText("ACTIVE_DEVICES")
        ccd_active_devices[0].setText("Telescope Simulator")
        self.indiclient.sendNewProperty(ccd_active_devices)

        # we should inform the indi server that we want to receive the
        # "CCD1" blob from this device
        self.indiclient.setBLOBMode(PyIndi.B_ALSO, ccd, "CCD1")

        ccd_ccd1 = device_ccd.getBLOB("CCD1")
        while not ccd_ccd1:
            time.sleep(0.5)
            ccd_ccd1 = device_ccd.getBLOB("CCD1")

        # a list of our exposure times

        # we use here the threading.Event facility of Python
        # we define an event for newBlob event

        ccd_exposure[0].setValue(exposure)
        self.indiclient.sendNewProperty(ccd_exposure)
        # wait for the ith exposure
        blobEvent.wait()

        # and meanwhile process the received one
        for blob in ccd_ccd1:
            print(
                "name: ",
                blob.getName(),
                " size: ",
                blob.getSize(),
                " format: ",
                blob.getFormat(),
            )
            # pyindi-client adds a getblobdata() method to IBLOB item
            # for accessing the contents of the blob, which is a bytearray in Python
            fits = blob.getblobdata()
            print("fits data type: ", type(fits))
            with open(filename, "wb") as binary_file:
                binary_file.write(blob.getblobdata())

            # here you may use astropy.io.fits to access the fits data
        # and perform some computations while the ccd is exposing
        # but this is outside the scope of this tutorial
        self.shooting = False
        self.lock.release()
        self.queue_out.put('2.SHOOTING IS FINISHED')

class IndiOrchestrator:

    def __init__(self):
        global blobEvent
        self.qin = SimpleQueue()
        self.qout = SimpleQueue()
        blobEvent = threading.Event()
        blobEvent.clear()
        self.indi = IndiPilot(self.qin, self.qout)
        self.indi.connect()
        self._operating = False
        self.platesolver = platesolver.PlateSolve()
        self.last_error = 0
        self.indi.telescope_connect()
        self.processing = False
        self.stacking = False
        self.last_image='./static/noimage.jpg'
        self.last_image_processed=None
        self.lock = threading.Lock()


        self.indi.sync(0,0)
        (cra, cdec)=self.indi.get_current_coordinates()
        logger.debug(' --- Current Position '+str(cra)+" ; "+str(cdec))



    def get_qout(self):
        return self.qout
    
    def take_picture(self, exposure: int, gain: int):
        self.indi.take_picture('/tmp/exposure.fits', exposure, gain,)

    def move_to(self, ra : float, dec: float, continue_picture : bool = True):
        self._operating = True
        self.thread = threading.Thread(target=self._move_to, args=(ra, dec, continue_picture))
        self.thread.start()
        return error.no_error()

    def _move_to(self, ra: float, dec : float, continue_picture : bool):
        self.lock.acquire()
        retry = 0
        (cra, cdec)=self.indi.get_current_coordinates()
        logger.debug(' --- Current Position '+str(cra)+" ; "+str(cdec))
        logger.debug(' --- going to '+str(ra)+" ; "+str(dec))

        while retry<10 and self._operating:
            logger.debug(' --- GOTO STARTED')
            self.indi.goto(ra*24/360,dec)
            logger.debug(' --- GOTO FINISHED')
            self.indi.take_picture('/tmp/platesolve'+str(retry)+'.fits',1,100)
            logger.debug(' --- PICTURE OK, SOLVING')
            ps_return = self.platesolver.resolve('/tmp/platesolve'+str(retry)+'.fits',ra,dec)
            self.last_image = '/tmp/platesolve'+str(retry)+'.fits'
            logger.debug(' SOLVER ERROR %i', ps_return['error'])
            logger.debug(' SOLVER COORDINATES (RA,DEC) : (%f),(%f)', ps_return['ra'],ps_return['dec'])
      
            if ps_return['error']==0:
                self.qout.put('   Solving solution %f,%f' % (ps_return['ra'],ps_return['dec']))
                logger.debug('Syncing telescope to new coordinates')
                self.indi.sync(ps_return['ra'],ps_return['dec'] )
                error_rate = sqrt((ps_return['ra']-ra)*(ps_return['ra']-ra)+(ps_return['dec']-dec)*(ps_return['dec']-dec))
                logger.debug(' SOLVER ERROR RATE %f', error_rate)
                if error_rate<MAX_PLATESOLVE_ERROR:
                    self.last_error = 0
                    self._operating = False
                    self.qout.put('3.GOTO FINISHED')
                    logger.debug('++++ GOTO FINISHED')
                    if continue_picture:
                        while self._operating:
                            self.indi.take_picture('/tmp/platesolve'+str(retry)+'.fits',1,100)
                            self.last_image = '/tmp/platesolve'+str(retry)+'.fits'

                    self.lock.release()
                    return 
            else:
                    logger.error("Error during platesolve (error, ra, dec) (%i), (%f), (%f)", ps_return['error'], ra, dec)
                    self.qout.put('   Solving failed') 
            retry += 1
        logger.debug('GOTO FAILED DUE TO MAX RETRY REACHED')
        self.last_error = error.ERROR_GOTO_FAILED
        self._operating = False
        self.qout.put('4.GOTO FAILED')
        self.lock.release()


    def stop_stacking(self):
        self.stacking = False

    def start_stacking(self, ra : float, dec : float):
        if self._operating:
            self._operating = False
        self.lock.acquire()
        self.stacking = True
        logger.debug(' --- START STACKING')
        picture = 0
        today = datetime.now().strftime("%Y-%m-%d_%H%M%S")
        
        working_dir = config.CONFIG["WORKFLOW"]["STORAGE_DIR"] + "/"+today+"/"
        logger.debug(' --- WORKING DIR %s' % working_dir)
        os.mkdir(working_dir)
        

        logger.debug(' --- TAKE REFERENCE')
        self.indi.take_picture(working_dir+str(picture)+'.fits',1,100)
        ref = open_fits(working_dir+str(picture)+'.fits')
        stacked = ref.clone()
        stack = 0
        logger.debug(' --- STACKING LOOP')
        while self.stacking:
            logger.debug(' --- SHOOTING')
            self.indi.take_picture(working_dir+str(picture)+'.fits', 1,100)
            logger.debug(' --- TREATING FITS')
            image = open_fits(working_dir+str(picture)+'.fits')
            hot_pixel_remover(image)
            debayer(image)
            adapt(image)
            logger.debug(' --- TRANSFORMING')
            transformation = find_transformation(image, ref)
            if transformation==None:
                logger.error("... No alignment point, skipping image %s ..." % (working_dir+str(picture)+'.fits'))
            else:
                logger.debug(' --- STACKING')
                apply_transformation(image, transformation, ref)
                stack_image(image, stacked, stack, 1)
                stack += 1
                stacked = image.clone()
                stretch(image, 0.18)
                normalize(image)
                logger.debug(' --- SAVING')
                save_jpeg(image,working_dir+str(picture)+str(picture)+'.jpg')
                logger.debug(' --- UPDATING STATUS FOR CLIENT')
                self.last_image=working_dir+str(picture)+str(picture)+'.jpg'
                self.qout.put('2.SHOOTING IS FINISHED')
                picture += 1
                if picture % 8 == 0 : 
                    logger.debug(' --- MOVE TO FOR REALIGN')
                    self.lock.release()
                    self._move_to(ra, dec,False)
                    self.lock.acquire()
        self.lock.release()