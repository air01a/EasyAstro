import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:easyastro/components/structure/pagestructure.dart';

class ScreenMap extends StatefulWidget {
  @override
  _ScreenMap createState() => _ScreenMap();
}

class _ScreenMap extends State<ScreenMap> {
  final viewTransformationController = TransformationController();

  @override
  void initState() {
    // Faites des actions initiales ici si nécessaire
    // myVariable = 'New Value';

    super.initState();
    //viewTransformationController.value = Matrix4.diagonal3Values(4.0, 4.0, 1.0);
    final zoomFactor = 2.0;
    final xTranslate = 300.0;
    final yTranslate = 300.0;
    viewTransformationController.value.setEntry(0, 0, zoomFactor);
    viewTransformationController.value.setEntry(1, 1, zoomFactor);
    viewTransformationController.value.setEntry(2, 2, zoomFactor);
    viewTransformationController.value.setEntry(0, 3, -xTranslate);
    viewTransformationController.value.setEntry(1, 3, -yTranslate);
  }

  @override
  Widget build(BuildContext context) {
    Image currentImage;
    if (kIsWeb) {
      currentImage = Image.network(
        'assets/appimages/map/starmap.jpg',
        repeat: ImageRepeat.repeatX,
      );
    } else {
      currentImage = Image(
          image: AssetImage('assets/appimages/map/starmap.jpg'),
          repeat: ImageRepeat.repeatX,
          width: 10000);
    }
    return PageStructure(
        body: Center(
            child: Scaffold(
                body: Center(
                    child: Stack(alignment: Alignment.center, children: [
      SizedBox(
          // Utiliser un container pour permettre à l'InteractiveViewer de prendre toute la place disponible
          width: double.infinity,
          height: double.infinity,
          child: InteractiveViewer(
              transformationController: viewTransformationController,
              boundaryMargin: const EdgeInsets.all(
                  double.infinity), // Marge autour de l'image

              minScale: 0.9, // Échelle minimale de zoom
              maxScale: 10.0, // Échelle maximale de zoom
              constrained: true,
              child: currentImage))
    ])))));
  }
}
