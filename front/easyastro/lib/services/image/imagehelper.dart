import 'package:image/image.dart' as img;
import 'package:easyastro/services/image/imagefilter.dart';
import 'package:easyastro/services/network/api.dart';
import 'dart:typed_data';
import 'dart:isolate';
import 'dart:math';
import 'package:easyastro/services/database/globals.dart';
import 'package:easyastro/services/database/configmanager.dart';

class ImageHelper {
  double r = 1.0;
  double g = 1.0;
  double b = 1.0;
  double stretch = 0;
  double white = 255;
  double black = 0;
  double midtones = 1.0;
  double contrast = 1;
  int stretchAlgo = 1;

  img.Image? original;
  Uint8List? encoded;

  int counter = 0;

  ReceivePort receivePort = ReceivePort();
  Function() callBack;

  final apiHelper = ApiBaseHelper();

  ImageHelper(this.callBack) {
    /*rootBundle.load('assets/appimages/Jupiter.jpg').then((value) {
      Uint8List bytes = value.buffer.asUint8List();
      image = img.decodeImage(bytes);
      original = image!.clone();
    },);*/
  }

  void generateEncoded() {
    if (original == null) return;

    img.Image image = original!.clone();
    ImageFilters.adjustColor(image,
        whites: white,
        blacks: black,
        midtones: midtones,
        contrast: contrast,
        rFactor: r,
        gFactor: g,
        bFactor: b);

    encoded = img.encodeJpg(image);
  }

  void downloadImage() async {
    var rng = Random().nextInt(999999999);

    ///telescope/last_picture
    apiHelper
        .get(ServerInfo().host, "/telescope/last_picture",
            queryParameters: {
              "v": "$counter.$rng",
              "process": "false",
              "size": (ConfigManager()
                      .configuration?["imageRatio"]
                      ?.value
                      .toString() ??
                  "0.5")
            },
            binary: true)
        .then((value) {
      original = img.decodeJpg(value);
      callBack();
    });
  }

  void getParameters() async {
    apiHelper.get(ServerInfo().host, "/telescope/processing",
        queryParameters: {}).then(
      (value) {
        r = value["r"];
        g = value["g"];
        b = value["b"];
        contrast = value["contrast"];
        stretch = value["stretch"];
        black = (value["blacks"] / 256).clamp(0, 255);
        white = (value["whites"] / 256).clamp(0, 255);
        midtones = (value["mids"]) + 0.0;
        stretchAlgo = value["stretchAlgo"];
      },
    );
  }

  Map<String, List<int>> getHistogram() {
    List<int> redHistogram = List.filled(256, 0);
    List<int> greenHistogram = List.filled(256, 0);
    List<int> blueHistogram = List.filled(256, 0);

    for (int i = 0; i < encoded!.length; i += 4) {
      int red = encoded![i];
      int green = encoded![i + 1];
      int blue = encoded![i + 2];

      redHistogram[red]++;
      greenHistogram[green]++;
      blueHistogram[blue]++;
    }
    return {
      'red': redHistogram,
      'green': greenHistogram,
      'blue': blueHistogram
    };
  }
}
