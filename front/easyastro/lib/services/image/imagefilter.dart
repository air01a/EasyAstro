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
      return ((value - midtones) * (white - midtones) ~/ (255 - midtones)) +
          midtones;
    }
  }

  static void levels(
      img.Image src, int black, int white, int midtones, int contrast) {
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
    img.contrast(src, contrast: contrast);
    img.gamma(src, gamma: midtones);
  }

  void stretchHistogram(img.Image image, double stretchFactor) {
    List<List<int>> channelValues = _getChannelValues(image);

    List<int> minValues = channelValues
        .map((channel) => channel.reduce((a, b) => a < b ? a : b))
        .toList();
    List<int> maxValues = channelValues
        .map((channel) => channel.reduce((a, b) => a > b ? a : b))
        .toList();

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);

        int red = pixel.r.toInt();
        int green = pixel.g.toInt();
        int blue = pixel.b.toInt();

        int stretchedRed = (((red - minValues[0]) * stretchFactor * 255) /
                (maxValues[0] - minValues[0]))
            .round();
        int stretchedGreen = (((green - minValues[1]) * stretchFactor * 255) /
                (maxValues[1] - minValues[1]))
            .round();
        int stretchedBlue = (((blue - minValues[2]) * stretchFactor * 255) /
                (maxValues[2] - minValues[2]))
            .round();

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
        num blue = pixel.b;

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
    num minV = min(minRed, min(minBlue, minGreen));
    num maxV = max(maxRed, max(maxBlue, maxGreen));
    return [
      [minRed, maxRed],
      [minGreen, maxGreen],
      [minBlue, maxBlue],
      [minV, maxV]
    ];
  }

  static img.Image adjustColor(img.Image src,
      {num blacks = 0,
      num whites = 255,
      num midtones = 1,
      num contrast = 1,
      num rFactor = 1,
      num gFactor = 1,
      num bFactor = 1}) {
    if (blacks >= whites) blacks = whites - 1;
    if (midtones <= 0) midtones = 0.1;

    List<List<num>> minMax = getMinMax(src);
    var mm = minMax[3];
    for (final frame in src.frames) {
      for (final p in frame) {
        num median = mm[1] - mm[0];
        num or =
            (((p.r - mm[0]) / median - 0.5) * contrast + 0.5) * median + mm[0];
        num og =
            (((p.g - mm[0]) / median - 0.5) * contrast + 0.5) * median + mm[0];
        num ob =
            (((p.b - mm[0]) / median - 0.5) * contrast + 0.5) * median + mm[0];

        num r = rFactor *
            (255 * pow(or, (1 / midtones)) ~/ pow(255, (1 / midtones)));
        num g =
            gFactor * 255 * pow(og, (1 / midtones)) ~/ pow(255, (1 / midtones));
        num b =
            bFactor * 255 * pow(ob, (1 / midtones)) ~/ pow(255, (1 / midtones));

        r = r.clamp(blacks, whites);
        g = g.clamp(blacks, whites);
        b = b.clamp(blacks, whites);

        r = 255 * (r - mm[0]) / (mm[1] - mm[0]);
        g = 255 * (g - mm[0]) / (mm[1] - mm[0]);
        b = 255 * (b - mm[0]) / (mm[1] - mm[0]);

        p
          ..r = r
          ..g = g
          ..b = b;
      }
    }

    return src;
  }
}
