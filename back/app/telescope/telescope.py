import time
import threading
from queue import SimpleQueue
from ..platesolve import platesolver
from math import sqrt, cos, sin, pi
from ..dependencies import error, config
import logging
import os
from ..models.telescopestatus import TelescopeInfo
from datetime import datetime
from signal import signal, SIGINT
from ..lib import Coordinates
from ..models.constants import DEG_TO_RAD

if config.PLATFORM==config.LINUX:
    from .drivers.indi import IndiPilot
else:
    from .drivers.ascom import ASCOMPilot

MAX_PLATESOLVE_ERROR=1
logger = logging.getLogger(__name__)


class TelescopeOrchestrator:
    
    currentStatus = TelescopeInfo()
    coordinates = Coordinates.Coordinates()


    def signal_handler(self, signal_received, frame):
        self._end = True


    def __init__(self, image_processor, capture_image=True):
        self.qin = SimpleQueue()
        self.qout = SimpleQueue()
        
        self.image_processor = image_processor
        
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

        self.lock = threading.Lock()
        self.ccd_orientation = 0
        self._end = False
        self.gain = 100


        self.dark_progress=0
        self.dark_total=0
        self._job_queue = []
        (cra, cdec)=self.indi.get_current_coordinates()
        logger.debug(' --- Current Position '+str(cra)+" ; "+str(cdec))
        signal(SIGINT, self.signal_handler)

        self.mainThread = threading.Thread(target=self._start_main_loop,args=([capture_image]))
        self.mainThread.start()

    def process_job(self):
        if len(self._job_queue)==0:
            return
    
        job = self._job_queue.pop()
        if job['action']=='move_to':
            logger.debug('+++ JOB MOVE TO %f,%f'%(job['ra'],job['dec']))
            self.stacking=False
            self.currentStatus.current_task = 'MOVETO'
            self.currentStatus.object=job['object']
            self._move_to(job['ra'],job['dec'],job['solver'], job['object'])
        elif job['action']=='stack':
            logger.debug('+++ JOB STACK %f,%f'%(job['ra'],job['dec']))
            self.currentStatus.current_task = 'STACKING'
            self.currentStatus.object = job['object']
            self._stack(job['ra'],job['dec'],job['object'])
        elif job['action']=='move_to_short':
            logger.debug('+++ JOB MOVE TO SHORT %f,%f'%(job['ra'],job['dec']))
            self._move_short(job['ra'],job['dec'])
        elif job['action']=='take_dark':
            logger.debug('+++ JOB TAKE DARK')
            self.currentStatus.current_task = 'TAKING DARK'
            self._take_dark()

    def get_status(self):
        return self.currentStatus

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
                    self.indi.take_picture('/tmp/current'+str(i)+'.fits',self.get_exposition(),self.gain)
                    self.image_processor.set_last_image('/tmp/current'+str(i)+'.fits')
                    self.qout.put('2.SHOOTING IS FINISHED')
                    if self.get_exposition() < 5:
                        time.sleep(3)
                    i=(i+1) % 10
                else:
                    time.sleep(1)
            else:
                time.sleep(1)

    def set_exposition_auto(self):
        self.currentStatus.exposition = -1
    
    def change_exposition(self, exposition : float):
        self.currentStatus.exposition = exposition

    def set_gain(self, gain : int):
        self.gain = gain

    def get_qout(self):
        return self.qout
    
    def take_picture(self, exposure: int, gain: int):
        self.indi.take_picture('/tmp/exposure.fits', exposure, gain,)

    def move_to(self, ra : float,  dec: float, obj: str, solver : bool = True):
        self._job_queue.append({'action':'move_to','ra':ra,'dec':dec, 'solver':solver, 'object':obj})
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
        self.currentStatus.ra = ra
        self.currentStatus.dec = dec


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
        # Maximum expo time in alt az mount
        # See https://www.californiaskys.com/field-rotation.html
        if (ra==None):
            return min(5.0,float(config.CONFIG['IMAGING']['MAX_EXPO_AUTO']))
        (az,alt) = self.coordinates.equatorial_to_altz(ra,dec)
        pixel_size = float(config.CONFIG['DEVICE']['PIXELSIZE']) 
        pixel_traversed = 0.0000729 *float(config.CONFIG['DEVICE']['SENSORDIAG']) * 1000 /pixel_size * cos(self.coordinates.get_location().lat.rad)*cos(az.rad)/cos(alt.rad)
        expo = 8 / pixel_traversed
        print(expo)
        return min(expo,float(config.CONFIG['IMAGING']['MAX_EXPO_AUTO']))
    
    def get_exposition(self,ra=None, dec = None):
        print(self.currentStatus.exposition)
        if self.currentStatus.exposition==-1:
            exposition = self.get_expo_auto(ra, dec)
        else:
            exposition = self.currentStatus.exposition
        return exposition


    def _move_to(self, ra: float, dec : float, solver : bool, object : str = '', refresh : bool = True):
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
        exposition = 1.5

        while retry<10 and self._operating:
            logger.debug(' --- GOTO STARTED')
            self.indi.goto(ra,dec)
            logger.debug(' --- GOTO FINISHED')
            
            self.indi.take_picture('/tmp/platesolve'+str(retry)+'.fits',exposition,self.gain)
            self.image_processor.set_last_image('/tmp/platesolve'+str(retry)+'.fits')
            if refresh:
                self.qout.put('2.SHOOTING IS FINISHED')

            logger.debug(' --- PICTURE OK, SOLVING')
            ps_return = self.platesolver.resolve('/tmp/platesolve'+str(retry)+'.fits',ra,dec)

            logger.debug(' SOLVER ERROR %i', ps_return['error'])
            logger.debug(' SOLVER COORDINATES (RA,DEC, ORIENTATION) : (%f),(%f),(%f)', ps_return['ra'],ps_return['dec'], ps_return['orientation'])

            if  ps_return['error']==0:
                self.ccd_orientation = ps_return['orientation']


            if ps_return['error']==0:
                self.qout.put('   Solving solution %f,%f,%f' % (ps_return['ra'],ps_return['dec'], ps_return['orientation']))
                logger.debug('Syncing telescope to new coordinates')
                self.indi.sync(ps_return['ra'],ps_return['dec'] )
                error_rate = sqrt((ps_return['ra']-ra)*(ps_return['ra']-ra)+(ps_return['dec']-dec)*(ps_return['dec']-dec))
                self.qout.put('6.PLATESOLVE DONE;%f' % error_rate)
                logger.debug(' SOLVER ERROR RATE %f', error_rate)
                self.currentStatus.ra = ps_return['ra']
                self.currentStatus.dec = ps_return['dec']
                if error_rate<MAX_PLATESOLVE_ERROR:
                    self.currentStatus.last_error = 0
                    self.qout.put('3.GOTO FINISHED')
                    logger.debug('++++ GOTO FINISHED')
                    self._operating = False
                    self.currentStatus.current_task = 'TRACKING'
                    self.currentStatus.object = object 
                    self.lock.release()
                    return 
            else:
                    logger.error("Error during platesolve (error, ra, dec) (%i), (%f), (%f)", ps_return['error'], ra, dec)
                    self.qout.put('7.PLATESOLVE %i FAILED, RETRYING' % retry) 
                    exposition = exposition + 0.5
                     
            retry += 1
        logger.debug('GOTO FAILED DUE TO MAX RETRY REACHED')
        self.currentStatus.last_error = error.ERROR_GOTO_FAILED
        self._operating = False
        self.qout.put('9.GOTO FAILED')
        self.currentStatus.current_task = 'IDLE'
        self.lock.release()

    def stack(self, ra : float, dec : float, obj: str):
        self._job_queue.append({'action':'stack','ra':ra,'dec':dec,'object':obj})

    def stop_stacking(self):
        self.currentStatus.stacking = False

    def _stack(self, ra : float, dec : float, object: str):
        if self._operating:
            self._operating = False
        self.lock.acquire()
        self.currentStatus.stacking = True
        logger.debug(' --- START STACKING')
        picture = 0
        today = datetime.now().strftime("%Y-%m-%d_%H%M%S")
        
        working_dir = config.CONFIG["WORKFLOW"]["STORAGE_DIR"] + "/"+today+"/"
        logger.debug(' --- WORKING DIR %s' % working_dir)
        os.mkdir(working_dir)
        

        logger.debug(' --- TAKE REFERENCE')
        self.indi.take_picture(working_dir+str(picture)+'.fits',self.get_exposition(ra, dec),self.gain)
        self.image_processor.init_stacking(working_dir+str(picture)+'.fits')
        
        logger.debug(' --- STACKING LOOP')
        while self.currentStatus.stacking:
            logger.debug(' --- SHOOTING')
            self.indi.take_picture(working_dir+str(picture)+'.fits', self.get_exposition(ra, dec),self.gain)
            logger.debug(' --- TREATING FITS')
            if self.image_processor.stack(working_dir+str(picture)+'.fits'):
                logger.debug(' --- UPDATING STATUS FOR CLIENT')
                self.qout.put('4. IMAGE ADDED TO STACK;%i,%i' % (self.image_processor.stacked, self.image_processor.discarded))

            else:
                self.qout.put('5. IMPOSSIBLE TO ADD IMAGE TO STACK;%i,%i' % (self.image_processor.stacked, self.image_processor.discarded)) 
            self.currentStatus.discarded = self.image_processor.discarded
            self.currentStatus.stacked = self.image_processor.stacked

            picture += 1
            if picture % 8 == 0 : 
                logger.debug(' --- MOVE TO FOR REALIGN')
                self.lock.release()
                self._move_to(ra, dec,True, object, False)
                self.lock.acquire()
        self.currentStatus.current_task = 'TRACKING'
        self.lock.release()
        