import 'package:sweph/sweph.dart';
import 'dart:math';


// Structure for storing right ascension, declinaison and object distance from jpl
class Coordinates {
  final double ra;
  final double dec;
  final double distance;
  const Coordinates(this.ra, this.dec, this.distance);

}


// Structure for storing rising hour, setting hour, culmination hour and if visible or not given the time of observation
class EphemerisParameters {
  final double rising;
  final double setting;
  final double culmination;
  final bool visible; 
  const EphemerisParameters(this.rising, this.setting, this.culmination, this.visible);
}



// Main class
class AstroCalc {

  double asTime=0; 
  double longitude = 0;
  double latitude = 0;
  double altitude = 0;
  int year = 0;
  int month = 0;
  int day = 0;
  double hour = 0;


  static Future<void> init() async {
        await Sweph.init(epheAssets: [
    "packages/sweph/assets/ephe/seas_18.se1", // For house calc
    "packages/sweph/assets/ephe/sefstars.txt", // For star name
    "packages/sweph/assets/ephe/seasnam.txt", // For asteriods
    ]);
  }

  // Constructor
  AstroCalc() {
    final now = DateTime.now();
    day = now.day;
    month = now.month;
    year = now.year;
    hour = now.hour + now.minute/60 + now.second / 3600;
    asTime = Sweph.swe_julday(year, month, day,hour, CalendarType.SE_GREG_CAL);
  }

  // Set observation date
  void setDate(int y, int m, int d, double h) {
    year = y; month = m; day = d; hour = h;
    asTime = Sweph.swe_julday(year, month, day,hour, CalendarType.SE_GREG_CAL);

  }

  // Define position for observer
  void setPosition(double long, double lat, double alt) {
    longitude = long;
    latitude = lat;
    altitude = alt;
  }


  // Calculate object position from JPL ephemerid
  Coordinates getObjectCoord(HeavenlyBody object) {
    final pos =
        Sweph.swe_calc_ut(asTime, object, SwephFlag.SEFLG_JPLEPH | SwephFlag.SEFLG_EQUATORIAL   );
    return Coordinates(pos.longitude, pos.latitude, pos.distance);
  }


  // Calculate local sidereal time given utc time and longitude
  double getSiderealTime() {
    int intHour = hour.toInt();
    int intMinute = ((hour - intHour)*60).toInt(); 
    int intSeconde = (((hour - intHour)*60 - intMinute)*60).toInt();

    final now = DateTime(year, month, day, intHour,intMinute,intSeconde).toUtc();

    final julianDay = now.millisecondsSinceEpoch / 86400000 + 2440587.5;
    final julianCenturies = (julianDay - 2451545) / 36525;
    final meanSiderealTime = 280.46061837 +
        360.98564736629 * (julianDay - 2451545) +
        0.000387933 * pow(julianCenturies, 2) -
        pow(julianCenturies, 3) / 38710000;
    
    final siderealTime = meanSiderealTime +
        longitude;
    return siderealTime % 360 / 15;
  }


  double calcH0() {
    double refractionCoeff = 34/60 *pi/180;
    double moonParallax = 0;
    double correctedAltitude = acos(6378140/(6378140+altitude));
    return moonParallax - refractionCoeff - correctedAltitude;
  }

  double? calcHourAngle(double dec) {
    double h0 = calcH0(); // Default hour angle, always the same. It's time sidereal that is changing day after day
    double radLat = latitude * pi / 180; // Convert to rad
    double radDec = dec * pi / 180; 
    double h =((sin(h0)-sin(radLat)*sin(radDec))/(cos(radLat)*cos(radDec))); // Calculate cos hour angle
    if (h.abs()>1) {
      return null;  // no rise and no set, means circumpolar
    }
    
    double cosH = acos(h)*180/pi; // Calculate angle
    return cosH;
  }

  EphemerisParameters calculateEphemeris(double ra, double dec, siderealTime) {

    double? ha = calcHourAngle(dec); // Calculate hour angle H = ts - alpha
    double st = siderealTime *15;
    double hRise;
    double hSet;
    double hCum  = (hour + ((ra-st))/15/1.002737909) % 24;
    bool visible = false;

    if (ha==null) { // Circumpolar
      hRise=0;
      hSet = 0;
      visible = true;
    } else { // Star with rise and set
      double tsRise = (st - (ra-ha))/15;
      double tsSet  = (st - (ra+ha))/15;
      hRise = hour  - tsRise/1.002737909; 
      hSet = hour - tsSet/1.002737909;
      if (hRise<hour && hSet>hour ) {
        visible = true;
      }
    }

    return EphemerisParameters(hRise,hSet,hCum, visible);

  }


}