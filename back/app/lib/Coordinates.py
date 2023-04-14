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

from pydantic import BaseModel

# Coord type 
class Coord(BaseModel):
    lon: float
    lat: float
    height : float

class StarCoord(BaseModel):
    ra: float
    dec: float


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
        self._constraints = [AltitudeConstraint(10*u.deg, 80*u.deg),
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
        for obj in objects:
            if obj in catalog.keys():
                 ret.append(catalog[obj])
        return ret
    
    def _take_second(self,elem):
        return elem[1]

    def get_schedule(self, targets, catalog):
        schedule = []
        sidereal_convertion = 366.25/365.25/15
        sidereal_time = self.get_sidereal_time()
        for object in catalog._catalog:
            if object.name in targets:
                schedule.append((object.name,((object.coord.ra-sidereal_time)*sidereal_convertion)))
        
        schedule.sort(key=self._take_second)
        return schedule
        