import PyIndi
import time
import sys
import threading
from queue import Queue
from ..platesolve import platesolver


blobEvent = None
class IndiClient(PyIndi.BaseClient):
    def __init__(self):
        super(IndiClient, self).__init__()

    def updateProperty(self, prop):
        global blobEvent
        if prop.getType() == PyIndi.INDI_BLOB:
            print("new BLOB ", prop.getName())
            blobEvent.set()

class IndiPilot():


    def __init__(self, queue_in : Queue, queue_out:Queue ):
        self.queue_in = queue_in
        self.queue_out = queue_out
        self.moving = False
        self.shooting = False
        self.platesolver = platesolver.PlateSolve()


    def connect(self):
        # connect the server
        self.indiclient = IndiClient()
        self.indiclient.setServer("localhost", 7624)

        if not self.indiclient.connectServer():
            print(
                "No indiserver running on "
                + self.indiclient.getHost()
                + ":"
                + str(self.indiclient.getPort())
                + " - Try to run"
            )
            print("  indiserver indi_simulator_telescope indi_simulator_ccd")
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
            self.telescope_connect[0].setState(PyIndi.ISS_ON)  # the "CONNECT" switch
            self.indiclient.sendNewProperty(self.telescope_connect)  # send this new value to the device


    def goto(self, ra, dec):
        self.thread = threading.Thread(target=self._goto, args=(ra,dec))
        self.thread.start()

    def _goto(self, ra, dec):
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
            print("Scope Moving ", telescope_radec[0].value, telescope_radec[1].value)
            self.queue_out.put("Scope Moving ", telescope_radec[0].value, telescope_radec[1].value)
            time.sleep(2)
        self.moving = False
        self.queue_out.put('1.MOVING IS FINISHED')

    def take_picture(self,filename : str, exposure : int, gain : int):
        
        self.thread = threading.Thread(target=self._take_picture, args=(filename, exposure  , gain))
        self.thread.start()

    def _take_picture(self, filename : str, exposure : int, gain : int, type : int = 0, binning : int = 0):
        global bobEvent
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
        self.queue_out.put('2.SHOOTING IS FINISHED')

class IndiOrchestrator:

    def __init__(self):
        global blobEvent
        self.qin = Queue()
        self.qout = Queue()
        blobEvent = threading.Event()
        blobEvent.clear()
        self.indi = IndiPilot(self.qin, self.qout)
        self.indi.connect()


    def move_to(self, ra, dec):
        self.indi.telescope_connect()

        retry = 0

        while retry<5:
            self.indi.goto(ra,dec)
            while True:
                print(self.qout.get())
                if self.indi.moving==False:
                    break
            self.indi.take_picture('/tmp/platesolve.fits',1,100)

            while True:
                print(self.qout.get())
                if self.indi.shooting==False:
                    break
            