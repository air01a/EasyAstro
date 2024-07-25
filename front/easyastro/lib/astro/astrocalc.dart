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
  final double height;
  final double ra;
  final double dec;
  final double azimuth;
  const EphemerisParameters(this.rising, this.setting, this.culmination,
      this.visible, this.azimuth, this.height, this.ra, this.dec);
}

class ConvertAngle {
  static hourToString(double hour) {
    hour = hour % 24;
    String h = (hour.floor()).toString();
    if (h.length == 1) h = "0$h";

    String m = ((hour - hour.floor()) * 60).floor().toString();
    if (m.length == 1) m = "0$m";

    return "${h}h$m";
  }

  static hourToStringWithSeconds(double hour) {
    hour = hour % 24;
    double minute = (hour - hour.floor()) * 60;
    double seconds = (minute - minute.floor()) * 60;

    return "${hour.toInt().toString().padLeft(2, '0')}:${minute.toInt().toString().padLeft(2, '0')}:${seconds.toInt().toString().padLeft(2, '0')}";
  }

  static raToString(double ra) {
    ra = ra % 24;
    String h = (ra.floor()).toString();
    if (h.length == 1) h = "0$h";

    int min = ((ra - ra.floor()) * 60).floor();
    String m = min.toString();
    if (m.length == 1) m = "0$m";

    int sec = (((ra - ra.floor()) * 60 - min) * 60).floor();
    String s = sec.toString();
    if (s.length == 1) s = "0$m";

    return "${h}h${m}m${s}s";
  }

  static degToHour(double deg) {
    double hour = deg / 15;
    return hourToString(hour);
  }


  static  double radians(double degrees) {
    return degrees * pi / 180.0;
  }

  // Conversion de radians en degrés
  static double degrees(double radians) {
    return radians * 180.0 / pi;
  }
}

// Main class
class AstroCalc {
  double asTime = 0;
  double longitude = 0;
  double latitude = 0;
  double altitude = 0;
  int year = 0;
  int month = 0;
  int day = 0;
  double hour = 0;
  int diffToUtc = 0;

  static Future<void> init() async {
    await Sweph.init(epheAssets: [
      "packages/sweph/assets/ephe/seas_18.se1", // For house calc
      "packages/sweph/assets/ephe/sefstars.txt", // For star name
      "packages/sweph/assets/ephe/seasnam.txt", // For asteriods
    ]);
  }

  void setCurrentTime() {
    final now = DateTime.now();
    int localHour = now.hour;
    int utcHour = now.toUtc().hour;

    diffToUtc = localHour - utcHour;

    day = now.day;
    month = now.month;
    year = now.year;
    hour = now.hour + now.minute / 60 + now.second / 3600;
    asTime = Sweph.swe_julday(year, month, day, hour, CalendarType.SE_GREG_CAL);
  }

  // Constructor
  AstroCalc() {
    setCurrentTime();
  }

  String getDate() {
    return "${year.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
  }

  String getDateTimeString() {
    int minute = ((hour - hour.floor()) * 60).floor();
    String tmp =
        "${year.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')} ${hour.floor().toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00";
    return tmp;
  }

  DateTime getDateTime({bool stringFormat = false}) {
    return DateTime.parse(getDateTimeString());
  }

  // Set observation date
  void setDate(int y, int m, int d, double h) {
    year = y;
    month = m;
    day = d;
    hour = h;
    asTime = Sweph.swe_julday(year, month, day, hour, CalendarType.SE_GREG_CAL);
  }

  // Define position for observer
  void setPosition(double long, double lat, double alt) {
    longitude = long;
    latitude = lat;
    altitude = alt;
  }

  // Calculate object position from JPL ephemerid
  AstroCoordinates getObjectCoord(HeavenlyBody object) {
    final pos = Sweph.swe_calc_ut(
        asTime, object, SwephFlag.SEFLG_JPLEPH | SwephFlag.SEFLG_EQUATORIAL);
    return AstroCoordinates(pos.longitude, pos.latitude, pos.distance);
  }

  List<int> getMoonPhaseForDate(int year, int month, int day, double hour) {
    asTime = Sweph.swe_julday(year, month, day, hour, CalendarType.SE_GREG_CAL);
    final ephemeride = Sweph.swe_pheno_ut(
        asTime, HeavenlyBody.SE_MOON, SwephFlag.SEFLG_TRUEPOS);

    // long-term avg duration 29.530587981 days (coverted to seconds)
    double lp = 2551442.8015584;
    DateTime date = DateTime(year, month, day, 20, 35, 0);
    // reference point new moon, the new moon at Jan 7th, 1970, 20:35.
    DateTime newMoon = DateTime(1970, 1, 7, 20, 35, 0);
    double phase =
        ((date.millisecondsSinceEpoch - newMoon.millisecondsSinceEpoch) /
                1000) %
            lp;
    int phase2 = (phase / (24 * 3600)).floor() + 1;
    return [(ephemeride[1] * 100).toInt(), phase2];
  }

  List<int> getMoonPhase() {
    return getMoonPhaseForDate(year, month, day, hour);
  }

  // Calculate local sidereal time given utc time and longitude
  double getSiderealTime() {
    int intHour = hour.toInt();
    int intMinute = ((hour - intHour) * 60).toInt();
    int intSeconde = (((hour - intHour) * 60 - intMinute) * 60).toInt();

    final now =
        DateTime(year, month, day, intHour, intMinute, intSeconde).toUtc();

    final julianDay = now.millisecondsSinceEpoch / 86400000 + 2440587.5;
    final julianCenturies = (julianDay - 2451545) / 36525;
    final meanSiderealTime = 280.46061837 +
        360.98564736629 * (julianDay - 2451545) +
        0.000387933 * pow(julianCenturies, 2) -
        pow(julianCenturies, 3) / 38710000;

    final siderealTime = meanSiderealTime + longitude;
    return siderealTime % 360 / 15;
  }

  int getMaxAltAzExposureTime(double lat, double az, double height,
      double sensorDiag, double pixelSize) {
    final double constante = 0.03645 * sensorDiag / pixelSize;
    double pixelTraversed = (constante *
            cos(lat * pi / 180) *
            cos(az * pi / 180) /
            cos(height * pi / 180))
        .abs();

    double expo = 4 / pixelTraversed;
    return min(30, expo.toInt());
  }

  // Calculate H0, always the same for a given object. Take into account parallax and refraction.
  double calcH0() {
    double refractionCoeff = 34 / 60 * pi / 180;
    double moonParallax = 0;
    double correctedAltitude = acos(6378140 / (6378140 + altitude));
    return moonParallax - refractionCoeff - correctedAltitude;
  }

  // Calculate Hour coordinates
  double? calcHourAngle(double dec) {
    double h0 =
        calcH0(); // Default hour angle, always the same. It's time sidereal that is changing day after day
    double radLat = latitude * pi / 180; // Convert to rad
    double radDec = dec * pi / 180;
    double h = ((sin(h0) - sin(radLat) * sin(radDec)) /
        (cos(radLat) * cos(radDec))); // Calculate cos hour angle
    if (h.abs() > 1) {
      return null; // no rise and no set, means circumpolar
    }

    double cosH = acos(h) * 180 / pi; // Calculate angle
    return cosH;
  }

  // Get object height at a given hour
  double getHeight(double dec, double h) {
    double decRad = dec * pi / 180;
    double latRad = latitude * pi / 180;
    double hRad = normalizeH(h);

    return asin(
        sin(decRad) * sin(latRad) + cos(decRad) * cos(latRad) * cos(hRad));
  }

  double normalizeH(double h) {
    double hRad = h * pi / 180;
    if (hRad < 0) hRad += 2 * pi;
    if (hRad > pi) hRad = hRad - 2 * pi;
    return hRad;
  }

  double? getAzimuth(double ra, double dec, double h) {
    double hRad = normalizeH(h);
    double lat = latitude * pi / 180;
    double azimuth = (180 / pi) *
            atan2(sin(hRad),
                (cos(hRad) * sin(lat) - tan(dec * pi / 180) * cos(lat))) -
        180;

    if (azimuth < 0) azimuth += 360;
    return azimuth;
  }

  // Calculate data for an object
  EphemerisParameters calculateEphemeris(double ra, double dec, siderealTime) {
    double? ha = calcHourAngle(dec); // Calculate hour angle H = ts - alpha
    double st = siderealTime * 15;

    double hRise;
    double hSet;
    double hCum = (hour + ((ra - st)) / 15 / 1.002737909) % 24;
    bool visible = false;
    double azimuth = getAzimuth(ra, dec, (st - ra)) ?? -1;
    double height = getHeight(dec, (st - ra)) * 180 / pi;
    if (ha == null) {
      // Circumpolar
      hRise = 0;
      hSet = 0;
      visible = true;
    } else {
      // Star with rise and set
      double tsRise = (st - (ra - ha)) / 15;
      double tsSet = (st - (ra + ha)) / 15;
      hRise = hour - tsRise / 1.002737909;
      hSet = hour - tsSet / 1.002737909;
      if (hRise < 0) hRise += 24;
      if (hSet < 0) hSet += 24;
      if (height > 0) visible = true;
    }

    return EphemerisParameters(
        hRise, hSet, hCum, visible, azimuth, height, ra, dec);
  }

  // Convert string name to HeaverlyBody object
  HeavenlyBody? getObjectName(String object) {
    switch (object) {
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

  // Get height for an object at multiple hour, to draw an azimutal chart
  Map<double, double> getAzimutalChart(
      double ra, double dec, double siderealTime) {
    Map<double, double> coord = {};
    double ha1;
    double ha2;
    double st = siderealTime;

    ha1 = st - 12;
    ha2 = st + 12;
    double ptr = ha1;

    while (ptr < ha2) {
      double hourAngle = (ptr * 15 - ra);
      double height = getHeight(dec, hourAngle) * 180 / pi;
      double h = (hour + (ptr - st) / (1.002737909));

      coord[h] = height;
      ptr += 1;
    }

    return coord;
  }


    // Fonction pour calculer la distance angulaire entre deux objets célestes
  double calculateAngularDistance(double azimuth1, double height1, double azimuth2, double height2) {
    double azimuthDiff = (azimuth1 - azimuth2).abs();
    if (azimuthDiff > 180) {
      azimuthDiff = 360 - azimuthDiff;
    }
    azimuthDiff = ConvertAngle.radians(azimuthDiff);
    height1 = ConvertAngle.radians(height1);
    height2 = ConvertAngle.radians(height2);

    double cosTheta = sin(height1) * sin(height2) + cos(height1) * cos(height2) * cos(azimuthDiff);
    return ConvertAngle.degrees(acos(cosTheta));
  }

  // Fonction pour vérifier si un objet est perturbé par la Lune
  bool isObjectPerturbedByMoon(double angularDistance, int moonIllumination) {
    //double angularDistance = calculateAngularDistance(objectAzimuth, objectHeight, moonAzimuth, moonHeight);

    // Définir le seuil de perturbation en fonction de l'éclairement de la Lune
    double perturbationThreshold;
    if (moonIllumination > 75) {
      perturbationThreshold = 10.0; // Seuil pour Lune très éclairée
    } else if (moonIllumination > 50) {
      perturbationThreshold = 7.5;
    } else if (moonIllumination > 25) {
      perturbationThreshold = 5.0;
    } else {
      perturbationThreshold = 2.5; // Seuil pour Lune peu éclairée
    }

    return angularDistance <= perturbationThreshold;
  }
}
