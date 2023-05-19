from os import (path, access, X_OK)
import subprocess
from ..dependencies import config

class PlateSolve(object):

    PS_POSSIBLE_PATH = ['/usr/bin/astrosolver']

    def __init__(self, astap_path = ""):

        if len(astap_path)>0 : 
            self.ASTAP_PATH = astap_path


        for astap_path in self.PS_POSSIBLE_PATH:
            if path.isfile(astap_path) and access(astap_path, X_OK):
                self.ASTAP_PATH = astap_path
                break
        self.CONFIG = config.CONFIG['PLATESOLVER']
        self.SEARCH_RADIUS = self.CONFIG.getint('SEARCH_RADIUS',10)
        self.DOWNSAMPLE_FACTOR = self.CONFIG.getint('DOWNSAMPLE_FACTOR', 0)
        self.MAX_STARS = self.CONFIG.getint('MAX_STARS',400)
        self.FOV = self.CONFIG.get('FOV','0.36')
        self.CATALOG = self.CONFIG['CATALOG']


    def _get_solution(self, fits):
        #wcs_path = path.splitext(fits)[0]+'.ini'
        if not path.isfile("/tmp/astro.result"):
            return (None, None)
        
        wcs_file = open("/tmp/astro.result", 'r')
        ra = None
        dec = None

        line = wcs_file.read()
        result = line.split(',')
        ra = float(result[0])
        dec = float(result[1])
        return (ra,dec)

    def _return(self, error, ra, dec):
        return {'error':error,'ra':ra,'dec':dec}

    def resolve(self, fits, ra=None, dec= None):
        astap_cmd = [
            self.ASTAP_PATH,
            fits
        ]
        result = subprocess.run(astap_cmd,capture_output=True, text=True)
        if result.returncode != 0 or not path.isfile('/tmp/platesolveok'):
            return {'error':1,'ra': ra,'dec': dec}
        (ra,dec) = self._get_solution(fits)
        return self._return( 2*int(ra==None),ra,dec)
        
'''
class PlateSolve(object):

    ASTAP_POSSIBLE_PATHS =  [
        '/usr/bin/astap_cli',
        '/opt/astap/astap_cli',
        '/usr/local/bin/astap_cli',
    ]

    def __init__(self, astap_path = ""):

        if len(astap_path)>0 : 
            self.ASTAP_PATH = astap_path

        for astap_path in self.ASTAP_POSSIBLE_PATHS:
            if path.isfile(astap_path) and access(astap_path, X_OK):
                self.ASTAP_PATH = astap_path
                break
        self.CONFIG = config.CONFIG['PLATESOLVER']
        self.SEARCH_RADIUS = self.CONFIG.getint('SEARCH_RADIUS',10)
        self.DOWNSAMPLE_FACTOR = self.CONFIG.getint('DOWNSAMPLE_FACTOR', 0)
        self.MAX_STARS = self.CONFIG.getint('MAX_STARS',400)
        self.FOV = self.CONFIG.get('FOV','0.36')
        self.CATALOG = self.CONFIG['CATALOG']

    def _get_solution(self, fits):
        wcs_path = path.splitext(fits)[0]+'.ini'
        if not path.isfile(wcs_path):
            return (None, None)
        
        wcs_file = open(wcs_path, 'r')
        ra = None
        dec = None

        for line in wcs_file.readlines():
            if line.find('CRVAL1') != -1:
                ra = float((line.split('='))[1])
            if line.find('CRVAL2') != -1:
                dec = float((line.split('='))[1])
        return (ra,dec)

    def _return(self, error, ra, dec):
        return {'error':error,'ra':ra,'dec':dec}

    def resolve(self, fits, ra=None, dec= None):
        astap_cmd = [
            self.ASTAP_PATH,
            '-f',
            fits,
            '-r', str(self.SEARCH_RADIUS),
            '-s', str(self.MAX_STARS),
            '-z', str(self.DOWNSAMPLE_FACTOR),
             '-d', self.CATALOG,
             '-update'
        ]
        result = subprocess.run(astap_cmd,capture_output=True, text=True)
        if result.returncode != 0:
            return {'error':1,'ra': ra,'dec': dec}
        (ra,dec) = self._get_solution(fits)
        return self._return( 2*int(ra==None),ra,dec)
        


#test = PlateSolve()
#print(test.resolve("../../../../M_97_Light_012.fits"))

'''