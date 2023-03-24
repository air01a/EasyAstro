from astropy.time import Time
from astropy.coordinates import solar_system_ephemeris, EarthLocation
from astropy.coordinates import get_body_barycentric, get_body, get_moon
from astropy.coordinates import AltAz, EarthLocation, SkyCoord
import astropy.units as u   
t = Time("2014-09-22 23:22")
loc = EarthLocation.of_site('greenwich') 
    with solar_system_ephemeris.set('builtin'):
        jup = get_body('jupiter', t, loc) 
print(jup)  

bear_mountain = EarthLocation(lat=41.3*u.deg, lon=-74*u.deg, height=390*u.m)
utcoffset = -4*u.hour  # Eastern Daylight Time
time = Time('2012-7-12 23:00:00') - utcoffset
m33 = SkyCoord.from_name('M33')
print(m33)  
m33altaz = m33.transform_to(AltAz(obstime=time,location=bear_mountain))
