import time
import asyncio
import threading
from queue import SimpleQueue
from ..platesolve import platesolver
from math import sqrt, cos, sin, pi
from ..dependencies import error, config
import logging
from ..models.image import Image
import os
from ..imageprocessor.utils import open_fits, open_process_fits, save_jpeg, adapt, normalize, debayer, save_to_bytes, reduce
from ..imageprocessor.filters import stretch, stretch, levels
from ..imageprocessor.align import find_transformation, apply_transformation
from ..imageprocessor.stack import stack_image
from datetime import datetime
from signal import signal, SIGINT

if config.PLATFORM==config.LINUX:
    from .drivers.indi import IndiPilot
else:
    from .drivers.ascom import ASCOMPilot

MAX_PLATESOLVE_ERROR=1
logger = logging.getLogger(__name__)


class IndiOrchestrator:

    stretch = 0.18
    whites = 65535
    blacks = 1
    mids = 1
    contrast = 1
    r = 1
    g = 1
    b = 1

    def process_last_image(self, process=True, size=1):
        ret = self.last_image.clone()
        if (self.stretch > 0):
            stretch(ret,self.stretch)
        
        if (process):    
            levels(ret, self.blacks,self.mids,self.whites, self.contrast, self.r, self.g, self.b)
    
        normalize(ret)

        img_bytes = save_to_bytes(ret,'JPG', size)
        return img_bytes.getvalue()

    def set_image_processing(self, stretch, blacks, midtones, whites, contrast, r, g, b):
        self.stretch=stretch
        self.whites = whites
        self.blacks = blacks
        self.mids = midtones
        self.r = r
        self.g = g
        self.b = b
        self.contrast = contrast

    def get_image_processing(self):
        return {"contrast":self.contrast, "stretch": self.stretch, "whites":self.whites, "blacks":self.blacks, "mids":self.mids, "r":self.r, "g":self.g, "b":self.b}

    def signal_handler(self, signal_received, frame):
        self._end = True


    def __init__(self, capture_image=True):
        self.qin = SimpleQueue()
        self.qout = SimpleQueue()
        if config.PLATFORM==config.LINUX:
            self.indi = IndiPilot(self.qin, self.qout)
        else:
            self.indi = ASCOMPilot(self.qin, self.qout)
        self._operating = False
        if config.CONFIG['PLATESOLVER']['PROGRAM']=='ASTRO.NET':
            self.platesolver = platesolver.PlateSolveAstroSolver()
        else:
            self.platesolver = platesolver.PlateSolveAstap()
        self.last_error = 0

        self.processing = False
        self.stacking = False
        self.last_image='./static/noimage.jpg'
        self.last_image_processed=None
        self.lock = threading.Lock()
        self.exposition = None
        self.ccd_orientation = 0
        self._end = False


        self.dark_progress=0
        self.dark_total=0
        self._job_queue = []
        (cra, cdec)=self.indi.get_current_coordinates()
        logger.debug(' --- Current Position '+str(cra)+" ; "+str(cdec))
        signal(SIGINT, self.signal_handler)

        self.mainThread = threading.Thread(target=self._start_main_loop,args=([capture_image]))
        self.mainThread.start()


    def setStretch(self, stretch):
        self.stretch = stretch

    def process_job(self):
        if len(self._job_queue)==0:
            return
    
        job = self._job_queue.pop()
        if job['action']=='move_to':
            logger.debug('+++ JOB MOVE TO %f,%f'%(job['ra'],job['dec']))
            self._move_to(job['ra'],job['dec'],job['solver'])
        elif job['action']=='stack':
            logger.debug('+++ JOB STACK %f,%f'%(job['ra'],job['dec']))
            self._stack(job['ra'],job['dec'])
        elif job['action']=='move_to_short':
            logger.debug('+++ JOB MOVE TO SHORT %f,%f'%(job['ra'],job['dec']))
            self._move_short(job['ra'],job['dec'])
        elif job['action']=='take_dark':
            logger.debug('+++ JOB TAKE DARK')
            self._take_dark()

    def shutdown(self):
        self._end = True

    def get_dark_progress(self):
        if self.dark_total==0:
            return 0
        return int(100*self.dark_progress/self.dark_total)

    def _move_short(self, ra : float,  dec : float):
        self.lock.acquire()
        self._operating=True
        self.indi.move_short(ra,dec)
        self.lock.release()
        self._operating=False

    def _start_main_loop(self, capture_image):
        i =0
        self.capture_image = capture_image

        while not self._end:
            if not self._operating:
                if len(self._job_queue)>0:
                    self.process_job()

                if self.capture_image:
                    #self.last_image = '/tmp/current'+str(i)+'.fits'
                    self.indi.take_picture('/tmp/current'+str(i)+'.fits',self.get_exposition(),100)
                    self.last_image = open_process_fits('/tmp/current'+str(i)+'.fits')
                    self.qout.put('2.SHOOTING IS FINISHED')
                #image = open_process_fits(self.last_image)

                #logger.debug(' --- FIND DRIFT')
                #transformation = find_transformation(image, ref)
                #if transformation==None:
                #    logger.error("... No alignment point, skipping image %s ..." % (self.last_image))
                #else:
                #    print("\nTranslation: (x, y) = ({:.2f}, {:.2f})".format(*transformation.translation))
                    if self.get_exposition() < 5:
                        time.sleep(3)
                    i=(i+1) % 10
                else:
                    time.sleep(1)
            else:
                #print('operating, delay taking picture')
                time.sleep(1)

    def set_exposition_auto(self):
        self.exposition = None
    
    def change_exposition(self, exposition : float):
        self.exposition = exposition

    def get_qout(self):
        return self.qout
    
    def take_picture(self, exposure: int, gain: int):
        self.indi.take_picture('/tmp/exposure.fits', exposure, gain,)

    def move_to(self, ra : float, dec: float, solver : bool = True):
        self._job_queue.append({'action':'move_to','ra':ra,'dec':dec, 'solver':solver})
        return error.no_error()
    
    def move_short(self, axis1: float, axis2 : float):
        if self._operating:
            return
        
        movement = 0.1
        axis1 = movement * axis1
        axis2 = axis2 * movement
        angle = self.ccd_orientation * pi/180
        ra = cos(angle)*axis1 - sin(angle)*axis2
        dec = sin(angle)*axis1 + cos(angle)*axis2
        if ra<0.09:
            ra = 0
        if dec<0.09:
            dec = 0
        self._job_queue.append({'action':'move_to_short','ra':ra,'dec':dec})


    def take_dark(self):
        self._job_queue.append({'action':'take_dark'})

    def _take_dark(self):
        expositions = [1,3,5,10,15]
        gains = [50, 100, 150, 200]
        self.dark_total = sum(expositions) * len(gains)
        self.dark_progress=0
        logger.debug(' --- START SHOOTING DARK LIBRARY')
        today = datetime.now().strftime("%Y-%m-%d")
        working_dir = config.CONFIG["WORKFLOW"]["STORAGE_DIR"] + "/"+today+"/"
        logger.debug(' --- WORKING DIR %s' % working_dir)
        if not os.path.isdir(working_dir):
            os.mkdir(working_dir)
        working_dir += '/dark/'
        if not os.path.isdir(working_dir):
            os.mkdir(working_dir)
        for expo in expositions:
            for gain in gains:
                self.indi.take_picture(working_dir+'dark_'+str(expo)+'_'+str(gain)+'.fits',expo,gain)
                self.dark_progress += expo
        



    def get_expo_auto(self, ra, dec):
        return float(config.CONFIG['IMAGING']['MAX_EXPO_AUTO'])
    
    def get_exposition(self,ra=None, dec = None):
        if self.exposition==None:
            exposition = self.get_expo_auto(ra, dec)
        else:
            exposition = self.exposition
        return exposition


    def _move_to(self, ra: float, dec : float, solver : bool, refresh : bool = True):
        if not solver:
            self._move_short(ra,dec)
            return
        self.lock.acquire()
        self._operating=True
        retry = 0
        (cra, cdec)=self.indi.get_current_coordinates()
        ra = ra * 24/360
        logger.debug(' --- Current Position '+str(cra)+" ; "+str(cdec))
        logger.debug(' --- going to '+str(ra)+" ; "+str(dec))
        exposition = 1
        gain = 500

        while retry<10 and self._operating:
            logger.debug(' --- GOTO STARTED')
            self.indi.goto(ra,dec)
            logger.debug(' --- GOTO FINISHED')
            #self.last_image = '/tmp/platesolve'+str(retry)+'.fits'
            
            self.indi.take_picture('/tmp/platesolve'+str(retry)+'.fits',exposition,gain)
            self.last_image = open_process_fits('/tmp/platesolve'+str(retry)+'.fits')
            if refresh:
                self.qout.put('2.SHOOTING IS FINISHED')

            logger.debug(' --- PICTURE OK, SOLVING')
            ps_return = self.platesolver.resolve('/tmp/platesolve'+str(retry)+'.fits',ra,dec)
            #self.last_image = '/tmp/platesolve'+str(retry)+'.fits'
            
    

            logger.debug(' SOLVER ERROR %i', ps_return['error'])
            logger.debug(' SOLVER COORDINATES (RA,DEC, ORIENTATION) : (%f),(%f),(%f)', ps_return['ra'],ps_return['dec'], ps_return['orientation'])

            if  ps_return['error']==0:
                self.ccd_orientation = ps_return['orientation']


            if ps_return['error']==0:
                self.qout.put('   Solving solution %f,%f,%f' % (ps_return['ra'],ps_return['dec'], ps_return['orientation']))
                logger.debug('Syncing telescope to new coordinates')
                self.indi.sync(ps_return['ra'],ps_return['dec'] )
                error_rate = sqrt((ps_return['ra']-ra)*(ps_return['ra']-ra)+(ps_return['dec']-dec)*(ps_return['dec']-dec))
                
                logger.debug(' SOLVER ERROR RATE %f', error_rate)
                if error_rate<MAX_PLATESOLVE_ERROR:
                    self.last_error = 0
                    self.qout.put('3.GOTO FINISHED')
                    logger.debug('++++ GOTO FINISHED')
                    self._operating = False
                    self.lock.release()
                    return 
            else:
                    logger.error("Error during platesolve (error, ra, dec) (%i), (%f), (%f)", ps_return['error'], ra, dec)
                    self.qout.put('   Solving failed - retrying')
                    exposition = exposition + 0.5
                     
            retry += 1
        logger.debug('GOTO FAILED DUE TO MAX RETRY REACHED')
        self.last_error = error.ERROR_GOTO_FAILED
        self._operating = False
        self.qout.put('4.GOTO FAILED')
        self.lock.release()

    def stack(self, ra : float, dec : float):
        self._job_queue.append({'action':'stack','ra':ra,'dec':dec})

    def stop_stacking(self):
        self.stacking = False

    def _stack(self, ra : float, dec : float):
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
        self.indi.take_picture(working_dir+str(picture)+'.fits',self.get_exposition(ra, dec),100)
        ref = open_process_fits(working_dir+str(picture)+'.fits')
        
        stacked = ref.clone()
        stack = 0
        logger.debug(' --- STACKING LOOP')
        while self.stacking:
            logger.debug(' --- SHOOTING')
            self.indi.take_picture(working_dir+str(picture)+'.fits', self.get_exposition(ra, dec),100)
            logger.debug(' --- TREATING FITS')
            image = open_process_fits(working_dir+str(picture)+'.fits')
            logger.debug(' --- TRANSFORMING')
            transformation = find_transformation(image, ref)
            #print("\nTranslation: (x, y) = ({:.2f}, {:.2f})".format(*transformation.translation))

            if transformation==None:
                logger.error("... No alignment point, skipping image %s ..." % (working_dir+str(picture)+'.fits'))
            else:
                logger.debug(' --- STACKING')
                apply_transformation(image, transformation, ref)
                stack_image(image, stacked, stack, 1)
                stack += 1
                stacked = image.clone()
                self.last_image = image.clone()
                stretch(image, self._stretch)
                normalize(image)
                logger.debug(' --- SAVING')
                save_jpeg(image,working_dir+str(picture)+str(picture)+'.jpg')
                logger.debug(' --- UPDATING STATUS FOR CLIENT')
                #self.last_image=working_dir+str(picture)+str(picture)+'.jpg'
                self.qout.put('2.SHOOTING IS FINISHED')
                picture += 1
                if picture % 8 == 0 : 
                    logger.debug(' --- MOVE TO FOR REALIGN')
                    self.lock.release()
                    self._move_to(ra, dec,True, False)
                    self.lock.acquire()
        self.lock.release()