import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DisplaySolarSystemHelper {
  DisplaySolarSystemHelper();

  double getSize() {
    if (kIsWeb) {
      return 200;
    }
    return 150;
  }

  Image getMoonImage(int imageNumber) {
    Image currentImage;
    imageNumber = (imageNumber * 24 / 30 % 24).toInt();

    if (kIsWeb) {
      currentImage = Image.network("assets/appimages/moon$imageNumber.png",
          width: getSize());
    } else {
      currentImage = Image(
          image: AssetImage("assets/appimages/moon$imageNumber.png"),
          width: getSize());
    }
    return currentImage;
  }

  Image getSunImage() {
    Image currentImage;
    if (kIsWeb) {
      currentImage =
          Image.network("assets/appimages/Sun.jpg", width: getSize());
    } else {
      currentImage = Image(
          image: const AssetImage("assets/appimages/Sun.jpg"),
          width: getSize());
    }
    return currentImage;
  }
}
