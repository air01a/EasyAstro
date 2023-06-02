import 'package:sweph/sweph.dart';
import 'dart:math';


// Structure for storing right ascension, declinaison and object distance from jpl
class AstroCoordinates {
  final double ra;
  final double dec;
  final double distance;
  const AstroCoordinates(this.ra, this.dec, this.distance);

}


// Structure for storing rising hour, setting hour, culmination hour and if visible or not given the time of observation
class EphemerisParameters {
  final double rising;
  final double setting;
  final double culmination;
  final bool visible; 
  const EphemerisParameters(this.rising, this.setting, this.culmination, this.visible);
}

class ConvertAngle {

  static hourToString(double hour) {
    hour = hour % 24;
    String h = (hour.floor()).toString();
    if (h.length==1) h = "0$h";

    String m = ((hour - hour.floor())*60).floor().toString();
    if (m.length==1) m = "0$m";

    return "$h:$m";

  }

  static degToHour(double deg) {
    double hour = deg / 15;
    return hourToString(hour);


  }
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
  AstroCoordinates getObjectCoord(HeavenlyBody object) {
    final pos =
        Sweph.swe_calc_ut(asTime, object, SwephFlag.SEFLG_JPLEPH | SwephFlag.SEFLG_EQUATORIAL   );
    return AstroCoordinates(pos.longitude, pos.latitude, pos.distance);
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

   HeavenlyBody? getObjectName(String object) {
    switch(object) {
      case 'Jupiter':
        return HeavenlyBody.SE_JUPITER;
      case 'Saturn':
        return HeavenlyBody.SE_SATURN;
      case 'Sun':
        return HeavenlyBody.SE_SUN;
      case 'Moon':
        return HeavenlyBody.SE_MOON;
      case 'Mars':
        return HeavenlyBody.SE_MARS;
      case 'Venus':
        return HeavenlyBody.SE_VENUS;
    }
    return null;
   } 

  double getHeight(double dec, double h) {
    double decRad = dec * pi / 180;
    double latRad = latitude * pi / 180;
    double hRad = h*pi/180;
    return asin(sin(decRad)*sin(latRad)+cos(decRad)*cos(latRad)*cos(h));
  }

  Map<int,double> getAzimutalChart(double ra, double dec,double siderealTime) {
    Map<int,double> coord = {};
    double? ha = calcHourAngle(dec);
    double ha1;
    double ha2;
    double st = siderealTime;print(siderealTime);
    double timeAtMeridian = (hour + ((ra-st))/15/1.002737909);

    ha1 = st - 12;
    ha2 = st + 12;
    double ptr=ha1;
    print(ra);
    print(ptr);
    print('--');
    while (ptr<ha2) {
      double hourAngle = (ptr*15 -ra);
      print(hourAngle);
      double height = getHeight(dec,hourAngle)*180/pi;
      double h = (hour + ptr/(15*1.002737909));
      print("$ptr:${ConvertAngle.hourToString(h)};$height");
      ptr+=1;
    }

    return coord;
  }
}