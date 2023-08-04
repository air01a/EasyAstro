import 'dart:math';
import 'package:easyastro/models/stars.dart';
import 'package:easyastro/models/skyobject.dart';

class Astro {
  static const double jdJ2000 = 2451545.0;
  static const double jd1970 = 2440587.5;
  static const double yearDays = 365.2422;
  static const int eqToEcl = 1;
  static const int eclToEq = -1;

  static double range(double v, double r) {
    return v - r * (v / r).floor();
  }

  static double degrad(double x) {
    return x * 1.74532925199433e-2;
  }

  static double raddeg(double x) {
    return x * 5.729577951308232e1;
  }

  static double hrrad(double x) {
    return x * 2.617993877991494e-1;
  }

  static double radhr(double x) {
    return x * 3.819718634205488;
  }

  static void aaHadec(double lat, List<double> from, List<double> to) {
    final double slat = sin(lat);
    final double clat = cos(lat);
    final double sx = sin(from[0]);
    final double cx = cos(from[0]);
    final double sy = sin(from[1]);
    final double cy = cos(from[1]);

    to[0] = atan2(-cy * sx, -cy * cx * slat + sy * clat);
    to[1] = asin(sy * slat + cy * clat * cx);
  }

  static void eclEq(int sw, List<double> from, List<double> to) {
    final double eps = degrad(23.45229444);
    final double seps = sin(eps);
    final double ceps = cos(eps);

    final double sy = sin(from[1]);
    double cy = cos(from[1]);
    if (cy.abs() < 1e-20) cy = 1e-20;
    final double ty = sy / cy;
    final double cx = cos(from[0]);
    final double sx = sin(from[0]);

    to[1] = asin((sy * ceps) - (cy * seps * sx * sw));
    to[0] = atan2(((sx * ceps) + (ty * seps * sw)), cx);
    to[0] = range(to[0], 2 * pi);
  }

  static void precess(double jd1, double jd2, List<double> coord) {
    double zetaA, zA, thetaA;
    double T;
    double A, B, C;
    double alpha, delta;
    double alphaIn, deltaIn;
    double fromEquinox, toEquinox;
    double alpha2000, delta2000;

    fromEquinox = (jd1 - Astro.jdJ2000) / Astro.yearDays;
    toEquinox = (jd2 - Astro.jdJ2000) / Astro.yearDays;
    alphaIn = coord[0];
    deltaIn = coord[1];

    // From fromEquinox to 2000.0
    if (fromEquinox != 0.0) {
      T = fromEquinox / 100.0;
      zetaA = degrad(T * (0.6406161 + T * (8.39e-5 + T * 5.0e-6)));
      zA = degrad(T * (0.6406161 + T * (3.041e-4 + T * 5.1e-6)));
      thetaA = degrad(T * (0.5567530 + T * (-1.185e-4 + T * 1.16e-5)));

      A = sin(alphaIn - zA) * cos(deltaIn);
      B = cos(alphaIn - zA) * cos(thetaA) * cos(deltaIn) +
          sin(thetaA) * sin(deltaIn);
      C = -cos(alphaIn - zA) * sin(thetaA) * cos(deltaIn) +
          cos(thetaA) * sin(deltaIn);

      alpha2000 = atan2(A, B) - zetaA;
      alpha2000 = range(alpha2000, 2 * pi);
      delta2000 = asin(C);
    } else {
      alpha2000 = alphaIn;
      delta2000 = deltaIn;
    }

    // From 2000.0 to toEquinox
    if (toEquinox != 0.0) {
      T = toEquinox / 100.0;
      zetaA = degrad(T * (0.6406161 + T * (8.39e-5 + T * 5.0e-6)));
      zA = degrad(T * (0.6406161 + T * (3.041e-4 + T * 5.1e-6)));
      thetaA = degrad(T * (0.5567530 + T * (-1.185e-4 + T * 1.16e-5)));

      A = sin(alpha2000 + zetaA) * cos(delta2000);
      B = cos(alpha2000 + zetaA) * cos(thetaA) * cos(delta2000) -
          sin(thetaA) * sin(delta2000);
      C = cos(alpha2000 + zetaA) * sin(thetaA) * cos(delta2000) +
          cos(thetaA) * sin(delta2000);

      alpha = atan2(A, B) + zA;
      alpha = range(alpha, 2.0 * pi);
      delta = asin(C);
    } else {
      alpha = alpha2000;
      delta = delta2000;
    }

    coord[0] = alpha;
    coord[1] = delta;
  }
}

class Observer {
  late double jd;
  late double longitude;
  late double latitude;
  late double lst;

  Observer() {
    final d = DateTime.now();
    final jan = DateTime(d.year, 1, 1);
    jd = Astro.jd1970 + d.millisecondsSinceEpoch / 86400000.0;
    longitude = Astro.degrad(-0.25 * jan.timeZoneOffset.inMinutes);
    latitude = Astro.degrad(40.0);
    initLST();
  }

  void setJD(double jd) {
    this.jd = jd;
    initLST();
  }

  DateTime getDate() {
    return DateTime.fromMillisecondsSinceEpoch(
        ((jd - Astro.jd1970) * 86400000.0).round());
  }

  void setDate(DateTime date) {
    jd = Astro.jd1970 + date.millisecondsSinceEpoch / 86400000.0;
    initLST();
  }

  void incHour(double count) {
    jd += count / 24.0;
    initLST();
  }

  int getLatDegrees() {
    return Astro.raddeg(latitude).round();
  }

  void setLatDegrees(double lat) {
    latitude = Astro.degrad(lat);
  }

  int getLonDegrees() {
    return Astro.raddeg(longitude).round();
  }

  void setLon(double lon) {
    longitude = lon;
    initLST();
  }

  void setLonDegrees(double lon) {
    longitude = Astro.degrad(lon);
    initLST();
  }

  double jdDay() {
    return (jd - 0.5).floorToDouble() + 0.5;
  }

  double jdHour() {
    return (jd - jdDay()) * 24.0;
  }

  void initLST() {
    lst = Astro.range(gst() + longitude, 2 * pi);
  }

  double gst() {
    final t = (jdDay() - Astro.jdJ2000) / 36525;
    final theta = 1.753368559146 +
        t * (628.331970688835 + t * (6.770708e-6 + t * -1.48e-6));
    return Astro.range(theta + Astro.hrrad(jdHour()), 2 * pi);
  }
}

class SkyPosTransformResult {
  double x = 0;
  double y = 0;
  bool visible = true;
  int color = 0;
  double? radius;
  bool? bright;
  String? name;
  String? abbrev;
}

class SkyPosition {
  double ra = 0;
  double dec = 0;
  int x = 0;
  int y = 0;
  bool visible = false;

  SkyPosition(double r, double d) {
    ra = r;
    dec = d;
  }
}

class SkyMapTransform {
  void skyposTransform(SkyObject star, Observer now, int w, int h) {
    final List<double> coord = [star.pos["ra"] + 0.0, star.pos["dec"] + 0.0];
    Astro.precess(Astro.jdJ2000, now.jd, coord);
    coord[0] = now.lst - coord[0];
    Astro.aaHadec(now.latitude, coord, coord);

    if (coord[1] < 0.15) {
      star.visible = false;
    } else {
      star.visible = true;
      final tmp = 0.5 - coord[1] / pi;
      star.pos["x"] = w * (0.5 - tmp * sin(coord[0]));
      star.pos["y"] = h * (0.5 - tmp * cos(coord[0]));
    }
  }

  void initStars(List<Star> star) {
    final clut = [
      0xFF94B1FF, // -0.4  32000
      0xFFADC6FF, // -0.1  12700
      0xFFCBDCFF, //  0.2   8400
      0xFFF0F5FF, //  0.5   6300
      0xFFFFF6E5, //  0.8   5100
      0xFFFFE7C2, //  1.1   4300
      0xFFFFDCA8, //  1.4   3800
      0xFFFFCE89, //  1.7   3300
      0xFFFFC475, //  2.0   3000
    ];

    for (final s in star) {
      if (s.mag < 3.5) {
        var cindex = ((8 * (s.bv + 0.4)) / 2.4).round();
        cindex = cindex.clamp(0, 8);
        s.color = clut[cindex];
        s.radius = 3.1 - 0.6 * s.mag; // 1.0 to 4.0
        s.bright = true;
      } else {
        final gray = 160 - ((s.mag - 3.5) * 100.0).round() + 4278190080;
        s.color = (1 << 24 | gray << 16 | gray << 8 | gray);

        s.radius = 1;
        s.bright = false;
      }
    }
  }
  /*
  void initDSOs(List<DeepSkyObject> dso) {
    final clut = [
      0xFFA0A040, // 1 open cluster
      0xFFA0A040, // 2 globular cluster
      0xFF40A060, // 3 nebula
      0xFF40A060, // 4 planetary nebula
      0xFF40A060, // 5 supernova remnant
      0xFFA04040, // 6 galaxy
      0xFF808080, // 7 other
    ];

    for (final d in dso) {
      d.color = clut[d.type - 1];
      d.offsetx = 4;
      d.offsety = -3;

      switch (d.catalog) {
        case 1:
          d.name = "M${d.id}";
          break;
        case 2:
          d.name = d.id.toString();
          break;
        case 0:
          d.name = d.id == 2 ? "SMC" : "LMC";
          break;
        default:
          d.name = " ";
      }


      switch (d.catalog) {
        case 1:
          switch (d.id) {
            case 8:
              d.offsetx = 4;
              d.offsety = 6;
              break;
            case 81:
              d.offsetx = -24;
              d.offsety = 0;
              break;
            case 86:
              d.offsetx = -24;
              break;
            default:
              break;
          }
          break;
        case 2:
          switch (d.id) {
            case 869:
              d.name = "869/884";
              break;
            default:
              break;
          }
          break;
        default:
          break;
      }
    }
  }

  void initPlanets(List<Planet> planet) {
    const seps = 0.397777156;
    const ceps = 0.917482062;

    for (final p in planet) {
      final so = sin(p.o);
      final co = cos(p.o);
      final si = sin(p.i);
      final ci = cos(p.i);
      final sw = sin(p.wb - p.o);
      final cw = cos(p.wb - p.o);

      final f1 = cw * so + sw * co * ci;
      final f2 = cw * co * ci - sw * so;

      p.P = [
        cw * co - sw * so * ci,
        ceps * f1 - seps * sw * si,
        seps * f1 + ceps * sw * si,
      ];
      p.Q = [
        -sw * co - cw * so * ci,
        ceps * f2 - seps * cw * si,
        seps * f2 + ceps * cw * si,
      ];

      switch (p.index) {
        case 2:
          p.radius = 5;
          break;
        case 8:
          p.radius = 2;
          break;
        default:
          p.radius = 3;
          break;
      }
      p.bright = true;

  }
    }*/
}
