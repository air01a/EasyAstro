import time
import threading
from app.dependencies import config
import logging
import PyIndi


logger = logging.getLogger(__name__)


blobEvent = None


class IndiClient(PyIndi.BaseClient):
    def __init__(self):
        global blobEvent 
        blobEvent = threading.Event()
        blobEvent.clear()
        super(IndiClient, self).__init__()

        self.logger = logging.getLogger('IndiClient')
        self.logger.info('creating an instance of IndiClient')

    def newDevice(self, d):
        '''Emmited when a new device is created from INDI server.'''
        self.logger.info(f"new device {d.getDeviceName()}")

    def removeDevice(self, d):
        '''Emmited when a device is deleted from INDI server.'''
        self.logger.info(f"remove device {d.getDeviceName()}")

    def newProperty(self, p):
        '''Emmited when a new property is created for an INDI driver.'''
        self.logger.info(f"new property {p.getName()} as {p.getTypeAsString()} for device {p.getDeviceName()}")


    def removeProperty(self, p):
        '''Emmited when a property is deleted for an INDI driver.'''
        self.logger.info(f"remove property {p.getName()} as {p.getTypeAsString()} for device {p.getDeviceName()}")

    def newMessage(self, d, m):
        '''Emmited when a new message arrives from INDI server.'''
        self.logger.info(f"new Message {d.messageQueue(m)}")

    def serverConnected(self):
        '''Emmited when the server is connected.'''
        self.logger.info(f"Server connected ({self.getHost()}:{self.getPort()})")

    def serverDisconnected(self, code):
        '''Emmited when the server gets disconnected.'''
        self.logger.info(f"Server disconnected (exit code = {code},{self.getHost()}:{self.getPort()})")


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

    def __init__(self, communication_callback ):
        self.communication_callback = communication_callback
        self.moving = False
        self.shooting = False
        self.lock = threading.Lock()
        self.connect()
        self.telescope_connect()
        self.ccd_connect()


    def connect(self):
        # connect the server
        self.indiclient = IndiClient()
        self.indiclient.setServer(config.CONFIG['INDI']['SERVER'], int(config.CONFIG['INDI']['PORT']))

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
        self.telescope = config.CONFIG['DEVICE']['TELESCOPE']
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
        #print(telescope_radec[0].getValue(), telescope_radec[1].getValue())
        return (telescope_radec[0].getValue(), telescope_radec[1].getValue())

    def move_short(self, delta_ra, delta_dec):
        '''test =  self.device_telescope.getSwitch("TELESCOPE_MOTION_NS")
        while not self.telescope_on_coord_set:
            time.sleep(1)
            self.telescope_on_coord_set = self.device_telescope.getSwitch("ON_COORD_SET")
        test.reset()
        test[1].setState(PyIndi.ISS_ON)
        self.indiclient.sendNewProperty(test)'''
        (ra,dec) = self.get_current_coordinates()
        print("Current Coordonnate ra,dec", ra, dec)
        print("GOTO ", ra+delta_ra, dec+delta_dec)
        self.goto(ra+delta_ra, dec+delta_dec)
        

    def goto(self, ra, dec):
        self.moving = True

        print(ra,dec)
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
            self.communication_callback(1,"Scope Moving %f %f" % (telescope_radec[0].value, telescope_radec[1].value),0)
            time.sleep(2)

        self.moving = False
        self.communication_callback(1,"MOVING IS FINISHED",0)


    def ccd_connect(self):
        self.ccd = config.CONFIG['DEVICE']['CCD']
        self.device_ccd = self.indiclient.getDevice(self.ccd)
        logger.debug(' --- Device CCD get connection ')
        while not (self.device_ccd):
            time.sleep(0.5)
            print('CCD GET CONNECTION')
            self.device_ccd = self.indiclient.getDevice(self.ccd)

        logger.debug(' --- Device CCD Connection ')
        self.ccd_connect = self.device_ccd.getSwitch("CONNECTION")
        while not (self.ccd_connect):
            time.sleep(0.5)
            print('DEVICE GET CONNECTION')

            self.ccd_connect = self.device_ccd.getSwitch("CONNECTION")
        if not (self.device_ccd.isConnected()):
            logger.debug(" --- Device CCD connected")
            self.ccd_connect.reset()
            self.ccd_connect[0].setState(PyIndi.ISS_ON)  # the "CONNECT" switch
            self.indiclient.sendNewProperty(self.ccd_connect)

        self.ccd_exposure = self.device_ccd.getNumber("CCD_EXPOSURE")
        while not (self.ccd_exposure):
            time.sleep(0.5)
            self.ccd_exposure = self.device_ccd.getNumber("CCD_EXPOSURE")

        # Ensure the CCD simulator snoops the telescope simulator
        # otherwise you may not have a picture of vega
        self.ccd_active_devices = self.device_ccd.getText("ACTIVE_DEVICES")
        while not (self.ccd_active_devices):
            time.sleep(0.5)
            print('GET ACTIVE')

            self.ccd_active_devices = self.device_ccd.getText("ACTIVE_DEVICES")
        self.ccd_active_devices[0].setText(self.telescope)
        self.indiclient.sendNewProperty(self.ccd_active_devices)

        # we should inform the indi server that we want to receive the
        # "CCD1" blob from this device
        self.indiclient.setBLOBMode(PyIndi.B_ALSO, self.ccd, "CCD1")

        self.ccd_ccd1 = self.device_ccd.getBLOB("CCD1")
        while not self.ccd_ccd1:
            time.sleep(0.5)
            self.ccd_ccd1 = self.device_ccd.getBLOB("CCD1")

    def take_picture(self, filename : str, exposure : float, gain : int, image_type : int = 0, binning : int = 0):
        
        logger.debug(' --- Taking picture with exposure %f' % exposure)

        self.lock.acquire()
        self.shooting = True

        blobEvent.clear()

        # a list of our exposure times

        # we use here the threading.Event facility of Python
        # we define an event for newBlob event

        self.ccd_exposure[0].setValue(exposure)
        self.indiclient.sendNewProperty(self.ccd_exposure)
        # wait for the ith exposure
        blobEvent.wait()

        # and meanwhile process the received one
        for blob in self.ccd_ccd1:
            #print(
            #    "name: ",
            #    blob.getName(),
            #    " size: ",
            #    blob.getSize(),
            #    " format: ",
            #    blob.getFormat(),
            #)
            # pyindi-client adds a getblobdata() method to IBLOB item
            # for accessing the contents of the blob, which is a bytearray in Python
            fits = blob.getblobdata()
            with open(filename, "wb") as binary_file:
                binary_file.write(blob.getblobdata())

            # here you may use astropy.io.fits to access the fits data
        # and perform some computations while the ccd is exposing
        # but this is outside the scope of this tutorial
        self.shooting = False
        self.lock.release()
        #self.queue_out.put('2.SHOOTING IS FINISHED')
        logger.debug(' ---2. Shooting is FINISHED')




