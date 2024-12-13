from astropy.time import Time
from astropy.coordinates import solar_system_ephemeris, EarthLocation, Angle
from astropy.coordinates import get_body_barycentric, get_body, get_moon
from astropy.coordinates import AltAz, EarthLocation, SkyCoord
import astropy.units as u  
from astroplan import Observer
from astropy.time import Time
from astroplan import (AltitudeConstraint, AirmassConstraint,
                       AtNightConstraint)
from astropy.table import Table
from astroplan import observability_table

from datetime import datetime,timedelta  
import pytz
from numpy import ndarray
import json
from ..models.coordinates import Coord, StarCoord

from pydantic import BaseModel


# Main Class
class Coordinates : 
    _location = None
    _time = None
    _duration = 1
    _timezone = 'Europe/Paris'

    def __init__(self):
        self._time = None
    
    def _to_json(self,value):
        if isinstance(value, list) or isinstance(value,tuple):
            result = []
            for line in value:
                result.append(self._to_json(line))
            return result
        
        if isinstance(value,Angle):
            return float(value.deg)

        if isinstance(value,SkyCoord):
            ra = value.ra.hour
            dec = value.dec.deg
            return {'ra':ra,'dec':dec}
              
        return value

    def get_location(self):
        return self._location

    def change_time_zone(self, value):
        self._timezone = value

    def to_json(self,value):
        return json.dumps(self._to_json(value))


    def set_location_site(self, location):
        self._location = EarthLocation.of_site(location)

    
    def set_location_coord (self, ulat, ulon, uheight):
        self._location = EarthLocation(lat = ulat * u.deg, lon = ulon * u.deg, height = uheight * u.m)
        self._observer = Observer(location=self._location,timezone=self._timezone)

    def set_time(self, time):
        self._time = Time(time)
    
    
    def get_planet(self, planet):
        with solar_system_ephemeris.set('builtin'):
            return get_body(planet, self._time, self._location) 

    def get_object(self, object):
        return SkyCoord.from_name(object)
    
    def get_sidereal_time(self):
        observing_time = Time(self._time, location=self._location)
        return observing_time.sidereal_time('mean')

    def get_sun_parameters(self):
        sun_set = self._observer.sun_set_time (self._time, which='nearest').datetime
        sun_rise = self._observer.sun_rise_time (self._time, which='nearest').datetime
        
        return (sun_rise, sun_set)

    def get_moon_parameters(self):
        moon_set = self._observer.moon_set_time (self._time, which='nearest').datetime
        moon_rise = self._observer.moon_rise_time (self._time, which='nearest').datetime
        return (moon_rise, moon_set, self._observer.moon_phase(self._time))

    def time_localize(self,date):
        return pytz.utc.localize(date).astimezone(pytz.timezone(self._timezone))

    def time_local_to_utc(self, date):
        tz = pytz.timezone(self._timezone)
        return tz.normalize(tz.localize(date)).astimezone(pytz.utc)

    def set_constraints(self):
        self._constraints = [AltitudeConstraint(10*u.deg, 88*u.deg),
               AirmassConstraint(5), AtNightConstraint.twilight_civil()]

    def get_catalog_visibility(self, catalog):
        targets = catalog._catalog
        ret = []
        time_range = [self._time, self._time+timedelta(hours=self._duration)]
        obs_table = observability_table(self._constraints, self._observer, targets, time_range=time_range)
        table = obs_table.as_array().tolist()
        for l in table : 
            if l[1]:
                ret.append(l)
        return ret
    
    def get_catalogs_objects(self, objects, catalog): 
        ret = []
        sideral_time = self.get_sidereal_time().hour
        for obj in objects:
            if obj in catalog.keys():
                 tmp = catalog[obj]
                 # Add delay before the object reach the meridian
                 tmp['meridian_time'] = self.get_meridian_time(tmp['RA']/15,sideral_time)
                 ret.append(tmp)
        return ret
    
    def _take_second(self,elem):
        return elem[1]

    def get_schedule(self, targets, catalog):
        schedule = []
        sidereal_convertion = 366.25/365.25/15
        sidereal_time = self.get_sidereal_time()
        for object in catalog._catalog:
            if object.name in targets:
                schedule.append((object.name,((object.coord.ra-sidereal_time)*sidereal_convertion).hour))
        
        schedule.sort(key=self._take_second)
        return schedule

    def get_meridian_time(self, ra, sidereal_time=None):
        sidereal_convertion = 366.25/365.25/15
        if sidereal_time == None:
            sidereal_time = self.get_sidereal_time().hour
        return ((ra-sidereal_time)*sidereal_convertion)
    
    def equatorial_to_altz(self, ra, dec):

        equatorial_coords = SkyCoord(ra=ra*u.deg, dec=dec*u.deg, frame='icrs')
        altaz_coords = equatorial_coords.transform_to(AltAz(obstime=self._time,location=self._location))
        return (altaz_coords.az, altaz_coords.alt)