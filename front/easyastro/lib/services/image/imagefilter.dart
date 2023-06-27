import 'package:image/image.dart' as img;
import 'dart:math';


class ImageFilters {

  static void rgb(img.Image src, double rp, double rg, double rb) {
    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        final pixel = src.getPixel(x, y);

        // Extract the RGB color channels
        int r = pixel.r.toInt();
        int g = pixel.g.toInt();
        int b = pixel.b.toInt();

        // Apply the brightness adjustment curve
        r = (r * rp).toInt().clamp(0, 255);
        g = (g * rg).toInt().clamp(0, 255);
        b = (b * rb).toInt().clamp(0, 255);

        // Update the pixel with the modified values
        src.setPixelRgb(x, y, r, g, b);
      }
    }
  }
//image.data = I16_BITS_MAX_VALUE * image.data ** (1 / midtones) / I16_BITS_MAX_VALUE ** (1 / midtones)
  static void contrast(img.Image src, double contrast) {
    int mean = 0;
    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        final pixel = src.getPixel(x, y);
        mean += pixel.luminance.toInt();
      }
    }
    mean = (mean ~/ (src.width * src.height)).clamp(0, 255);

    // Apply the contrast adjustment curve
    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        final pixel = src.getPixel(x, y);

        // Extract the RGB color channels
        int r = pixel.r.toInt();
        int g = pixel.g.toInt();
        int b = pixel.b.toInt();
        // Calculate the difference from the mean value
        int dr = r - mean;
        int dg = g - mean;
        int db = b - mean;

        // Scale the difference based on the contrast factor
        dr = (dr * contrast).toInt().clamp(-255, 255);
        dg = (dg * contrast).toInt().clamp(-255, 255);
        db = (db * contrast).toInt().clamp(-255, 255);

        // Update the pixel with the modified values
        r = (mean + dr).clamp(0, 255);
        g = (mean + dg).clamp(0, 255);
        b = (mean + db).clamp(0, 255);
        src.setPixelRgb(x, y, r, g, b);
      }
    }

  }


  static int _adjustLevel(int value, int white, int black, int midtones) {
    if (value < black) {
      return 0;
    } else if (value > white) {
      return 255;
    } else if (value < midtones) {
      return (value * (midtones - black) ~/ midtones) + black;
    } else {
      return ((value - midtones) * (white - midtones) ~/ (255 - midtones)) + midtones;
    }
  
  }

  static void levels(img.Image src, int black, int white, int midtones, int contrast) {


    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        final pixel = src.getPixel(x, y);

        // Extract the RGB color channels
        int r = _adjustLevel(pixel.r.toInt(), white, black, midtones);
        int g = _adjustLevel(pixel.g.toInt(), white, black, midtones);
        int b = _adjustLevel(pixel.b.toInt(), white, black, midtones);
        // Calculate the difference from the mean value
        src.setPixelRgb(x, y, r, g, b);
      }
    }
    img.contrast(src, contrast:contrast);
    img.gamma(src, gamma: midtones);
  }


  void stretchHistogram(img.Image image, double stretchFactor) {


    List<List<int>> channelValues = _getChannelValues(image);

    List<int> minValues = channelValues.map((channel) => channel.reduce((a, b) => a < b ? a : b)).toList();
    List<int> maxValues = channelValues.map((channel) => channel.reduce((a, b) => a > b ? a : b)).toList();

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);

        int red = pixel.r.toInt();
        int green = pixel.g.toInt();
        int blue = pixel.b.toInt();

        int stretchedRed = (((red - minValues[0]) * stretchFactor * 255) / (maxValues[0] - minValues[0])).round();
        int stretchedGreen = (((green - minValues[1]) * stretchFactor * 255) / (maxValues[1] - minValues[1])).round();
        int stretchedBlue = (((blue - minValues[2]) * stretchFactor * 255) / (maxValues[2] - minValues[2])).round();


        stretchedRed = stretchedRed.clamp(0, 255);
        stretchedGreen = stretchedGreen.clamp(0, 255);
        stretchedBlue = stretchedBlue.clamp(0, 255);

        image.setPixelRgb(x, y, stretchedRed, stretchedGreen, stretchedBlue);
      }
    }
  }

  List<List<int>> _getChannelValues(img.Image image) {
    List<List<int>> channelValues = List.generate(3, (_) => []);

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        int red = pixel.r.toInt();
        int green = pixel.g.toInt();
        int blue = pixel.b.toInt();

        channelValues[0].add(red);
        channelValues[1].add(green);
        channelValues[2].add(blue);
      }
    }

    return channelValues;
  }

  static num mix(num x, num y, num a) => x * (1 - a) + y * a;

  //contrast increases (> 1) / decreases (< 1) 
  //black/whites/mids : colors
  //saturation increases (> 1) / decreases (< 1)
  //brightness is a constant scalar of the image colors. At 0 the image is black, 1.0 unmodified, and > 1.0 the image becomes brighter.
  //gamma At < 1.0 the image becomes brighter, and > 1.0 the image becomes darker. A gamma of 1/2.2 will convert the image colors to linear color space.
  //exposure: exposure is an exponential scalar of the image as rgb/// pow(2, exposure). At 0, the image is unmodified; as the exposure increases, the image brightens.
  //hue: A hue of 0 will have no affect, and a hue of 45 will shift the hue of all colors by 45 degrees.
  //amount controls how much affect this filter has on the src image, where 0.0 has no effect and 1.0 has full effect.


  static List<List<num>> getMinMax(img.Image src) {
    num minRed = 255;
    num maxRed = 0;
    num minGreen = 255;
    num maxGreen = 0;
    num minBlue = 255;
    num maxBlue = 0;


    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        img.Pixel pixel = src.getPixel(x, y);

        num red = pixel.r;
        num green = pixel.g;
        num blue =pixel.b;

        if (red < minRed) {
          minRed = red;
        }
        if (red > maxRed) {
          maxRed = red;
        }

        if (green < minGreen) {
          minGreen = green;
        }
        if (green > maxGreen) {
          maxGreen = green;
        }

        if (blue < minBlue) {
          minBlue = blue;
        }
        if (blue > maxBlue) {
          maxBlue = blue;
        }
      }
    }
    num minV = min(minRed,min(minBlue, minGreen));
    num maxV = max(maxRed,max(maxBlue, maxGreen));
    return [[minRed, maxRed],[minGreen, maxGreen], [minBlue, maxBlue], [minV, maxV]];
  }

  static img.Image adjustColor(img.Image src,
    {num blacks=0,
    num whites=255,
    num midtones=1,
    num? contrast,
    num rFactor=1,
    num gFactor=1,
    num bFactor=1
    }) {
    

    if (blacks>=whites) blacks = whites - 1;
    if (midtones<=0) midtones=0.1;

    for (final frame in src.frames) {
      for (final p in frame) {
      

        num or = p.r;
        num og = p.g;
        num ob =p.b;

        num r = rFactor * (255*pow(or,(1/midtones)) ~/ pow(255,(1/midtones)));
        num g = gFactor * 255*pow(og,(1/midtones)) ~/ pow(255,(1/midtones));
        num b = bFactor * 255*pow(ob,(1/midtones)) ~/ pow(255,(1/midtones));
        //print("$r $blacks $whites");

        r=r.clamp(blacks, whites);
       // print("$r");
        g=g.clamp(blacks,whites);
        b=b.clamp(blacks, whites);

       // src.setPixel(x,y, img.ColorRgb8(r.toInt(), g.toInt(), b.toInt()));
        p
          ..r = r
          ..g = g
          ..b = b ;


      }
    }


    List<List<num>> minMax = getMinMax(src);
    num minR = minMax[0][0];
    num maxR = minMax[0][1];
    num minG = minMax[1][0];
    num maxG = minMax[1][1];
    num minB = minMax[2][0];
    num maxB = minMax[2][1];
    num alphaR = 255/(maxR - minR); num betaR = -alphaR * minR;
    num alphaG = 255/(maxG - minG); num betaG = -alphaG * minG;
    num alphaB = 255/(maxB - minB); num betaB = -alphaB * minB;

    final num minV = minMax[3][0];
    final num maxV = minMax[3][1];

    final num median = maxV - minV;


    for (final frame in src.frames) {
      for (final p in frame) {
        final or = (((p.r - minV)/median - 0.5) * contrast! + 0.5) * median + minV;
        final og =(((p.g - minV)/median - 0.5) * contrast+ 0.5) * median + minV;
        final ob = (((p.b - minV)/median - 0.5) * contrast + 0.5) * median + minV;
        p 
          ..r = (or * alphaR + betaR).clamp(0,255)
          ..g = (og * alphaG + betaG).clamp(0,255)
          ..b = (ob * alphaB + betaB).clamp(0,255);


      }
    }
    
    return src;
  }




}


/*
    if (amount == 0) {
      return src;
    }


    gamma = gamma?.clamp(0, 1000);
    exposure = exposure?.clamp(0, 1000);
    amount = amount.clamp(0, 1000);

    const degToRad = 0.0174532925;
    const avgLumR = 0.5;
    const avgLumG = 0.5;
    const avgLumB = 0.5;
    const lumCoeffR = 0.2125;
    const lumCoeffG = 0.7154;
    const lumCoeffB = 0.0721;

    final useBlacksWhitesMids = blacks != null || whites != null || mids != null;
    late num br, bg, bb;
    late num wr, wg, wb;
    late num mr, mg, mb;


    if (useBlacksWhitesMids) {

      print("${blacks!.r} ${blacks.g} ${blacks.b}");

      br = blacks?.rNormalized ?? 0;
      bg = blacks?.gNormalized ?? 0;
      bb = blacks?.bNormalized ?? 0;
      print("$br");
      wr = whites?.rNormalized ?? 0;
      wg = whites?.gNormalized ?? 0;
      wb = whites?.bNormalized ?? 0;

      mr = mids?.rNormalized ?? 0;
      mg = mids?.gNormalized ?? 0;
      mb = mids?.bNormalized ?? 0;

      mr = 1.0 / (1.0 + 2.0 * (mr - 0.5));
      mg = 1.0 / (1.0 + 2.0 * (mg - 0.5));
      mb = 1.0 / (1.0 + 2.0 * (mb - 0.5));


      print("$br $wr $mr");
    }

    final num invSaturation =
        saturation != null ? 1.0 - saturation.clamp(0, 1) : 0.0;
    final num invContrast = contrast != null ? 1.0 - contrast.clamp(0, 1) : 0.0;
    print("invcontrat $invContrast");
    if (exposure != null) {
      exposure = pow(2.0, exposure);
    }

    late num hueR;
    late num hueG;
    late num hueB;
    if (hue != null) {
      hue *= degToRad;
      final s = sin(hue);
      final c = cos(hue);

      hueR = (2.0 * c) / 3.0;
      hueG = (-sqrt(3.0) * s - c) / 3.0;
      hueB = ((sqrt(3.0) * s - c) + 1.0) / 3.0;
    }

    for (final frame in src.frames) {
      for (final p in frame) {
        final or = p.rNormalized;
        final og = p.gNormalized;
        final ob = p.bNormalized;

        var r = or;
        var g = og;
        var b = ob;

        if (useBlacksWhitesMids) {
          r = pow((r + br) * wr, mr);
          g = pow((g + bg) * wg, mg);
          b = pow((b + bb) * wb, mb);
        }

        if (brightness != null && brightness != 1.0) {
          final tb = brightness.clamp(0, 1000);
          r *= tb;
          g *= tb;
          b *= tb;
        }

        if (saturation != null) {
          final num lum = r * lumCoeffR + g * lumCoeffG + b * lumCoeffB;

          r = lum * invSaturation + r * saturation;
          g = lum * invSaturation + g * saturation;
          b = lum * invSaturation + b * saturation;
        }

        if (contrast != null) {
          r = avgLumR * invContrast + r * contrast;
          g = avgLumG * invContrast + g * contrast;
          b = avgLumB * invContrast + b * contrast;
        }

        if (gamma != null) {
          r = pow(r, gamma);
          g = pow(g, gamma);
          b = pow(b, gamma);
        }

        if (exposure != null) {
          r = r * exposure;
          g = g * exposure;
          b = b * exposure;
        }

        if (hue != null && hue != 0.0) {
          final hr = r * hueR + g * hueG + b * hueB;
          final hg = r * hueB + g * hueR + b * hueG;
          final hb = r * hueG + g * hueB + b * hueR;

          r = hr;
          g = hg;
          b = hb;
        }

        if (rFactor!=null && gFactor!=null && bFactor!=null ) {
          num factor = rFactor + gFactor + bFactor;
          r = 3*(r * rFactor / factor);
          g = 3*(g * gFactor / factor);
          b = 3*(b * bFactor / factor);
        }


        final msk =
            mask?.getPixel(p.x, p.y).getChannelNormalized(maskChannel) ?? 1;
        final blend = msk * amount;

        r = mix(or, r, blend);
        g = mix(og, g, blend);
        b = mix(ob, b, blend);

        p
          ..rNormalized = r
          ..gNormalized = g
          ..bNormalized = b;
      }
    }*/
/*
class Stretch {
  double shadowsClip;
  double targetBkg;

  Stretch({this.targetBkg = 0.25, this.shadowsClip = -2});

  double _getAvgDev(List<double> data) {
    double median = data.reduce((a, b) => a + b) / data.length;
    int n = data.length;
    double avgDev = 0;

    for (int i = 0; i < n; i++) {
      avgDev += (data[i] - median).abs() / n;
    }

    return avgDev;
  }

  List<double> _mtf(double m, List<double> x) {
    List<double> result = [];

    for (int i = 0; i < x.length; i++) {
      if (x[i] == 0) {
        result.add(0);
      } else if (x[i] == m) {
        result.add(0.5);
      } else if (x[i] == 1) {
        result.add(1);
      } else {
        double numerator = (m - 1) * x[i];
        double denominator = ((2 * m - 1) * x[i]) - m;
        result.add(numerator / denominator);
      }
    }

    return result;
  }

  Map<String, double> _getStretchParameters(List<double> data) {
    double median = data.reduce((a, b) => a + b) / data.length;
    double avgDev = _getAvgDev(data);

    double c0 = (median + (shadowsClip * avgDev)).clamp(0, 1).toDouble();
    double m = _mtf(targetBkg, [median - c0])[0];

    return {
      "c0": c0,
      "c1": 1,
      "m": m,
    };
  }

  List<double> stretch(List<double> data) {
    double maxData = data.reduce((a, b) => a > b ? a : b);

    List<double> d = data.map((value) => value / maxData).toList();

    Map<String, double> stretchParams = _getStretchParameters(d);
    double m = stretchParams["m"];
    double c0 = stretchParams["c0"];
    double c1 = stretchParams["c1"];

    List<double> stretchedData = [];

    for (int i = 0; i < d.length; i++) {
      if (d[i] < c0) {
        stretchedData.add(0);
      } else {
        double numerator = d[i] - c0;
        double denominator = 1 - c0;
        double value = m * (numerator / denominator);
        stretchedData.add(value);
      }
    }

    return stretchedData;
  }
}*/