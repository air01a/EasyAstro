import logging
import PyIndi
from io import StringIO 
#import astropy.io.fits as pyfits    
#import cv2
from datetime import datetime
from threading import Thread
import sys

class IndiClient(PyIndi.BaseClient):
 
    roi = None
    device = None
    run = True
    gain = 15.0
    exposure_time = 1.0
 
    def __init__(self):
        super(IndiClient, self).__init__()
        self.logger = logging.getLogger('PyQtIndi.IndiClient')
        self.logger.info('creating an instance of PyQtIndi.IndiClient')
    def disconnectServer(self):
        return PyIndi.BaseClient.disconnectServer(self)
        self.run = False 
    def newDevice(self, d):
        self.logger.info("new device " + d.getDeviceName())
        self.device = d
    def newProperty(self, p):
        self.logger.info("new property "+ p.getName() + " for device "+ p.getDeviceName())
        if p.getName() == "CONNECTION":
            self.connectDevice(self.device.getDeviceName())
        if p.getName() == "CCD_EXPOSURE":
            self.takeExposure()
        if p.getName() == "CCD_GAIN":
            gain = self.device.getNumber("CCD_GAIN")
            gain[0].value = self.gain
            self.sendNewNumber(gain)
    def removeProperty(self, p):
        self.logger.info("remove property "+ p.getName() + " for device "+ p.getDeviceName())
    def newBLOB(self, bp):
        self.logger.info("new BLOB ")
        img = bp.getblobdata()
        ### process data in new Thread
        Thread(target=self.process_image, args=(img,)).start()
        if self.run:
            self.takeExposure()

    def newSwitch(self, svp):
        self.logger.info ("new Switch "+ svp.name.decode() + " for device "+ svp.device.decode())
    def newNumber(self, nvp):
        self.logger.info("new Number "+ nvp.name.decode() + " for device "+ nvp.device.decode())
        print(nvp[0].value)
    def newText(self, tvp):
        self.logger.info("new Text "+ tvp.name.decode() + " for device "+ tvp.device.decode())
    def newLight(self, lvp):
        self.logger.info("new Light "+ lvp.name.decode() + " for device "+ lvp.device.decode())
    def newMessage(self, d, m):
        #self.logger.info("new Message "+ m)
        self.logger.info("New Message")
        print("MESSAGE", m)
    def serverConnected(self):
        self.logger.info("Server connected ("+self.getHost()+":"+str(self.getPort())+")")
    def serverDisconnected(self, code):
        self.logger.info("Server disconnected (exit code = "+str(code)+","+str(self.getHost())+":"+str(self.getPort())+")")
    def takeExposure(self):
        self.logger.info("<<<<<<<< Exposure >>>>>>>>>")
        exp = self.device.getNumber("CCD_EXPOSURE")
        exp[0].value = self.exposure_time
        self.sendNewNumber(exp)
        print(">>>> END EXPOSURe")
    def process_image(self, imgdata):
        print(">>>> Process image")
        blobfile=StringIO.StringIO(imgdata)
        with open("/tmp/test.fits", 'wb') as f:
            f.write(blobfile)
        #hdulist=pyfits.open(blobfile)
        #scidata = hdulist[0].data
        #if self.roi is not None:
        #    scidata = scidata[self.roi[1]:self.roi[1]+self.roi[3], self.roi[0]:self.roi[0]+self.roi[2]]
        #hdulist[0].data = scidata
        #hdulist.writeto("%s.fit" % datetime.now())
        #cv2.imwrite("%s.png" % datetime.now() , scidata)
        #cv2.imwrite("%s.jpg" % datetime.now() , scidata)
 
logging.basicConfig(format='%(asctime)s %(message)s', level=logging.INFO)
