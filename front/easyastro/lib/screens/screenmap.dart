import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:easyastro/components/structure/pagestructure.dart';

class ScreenMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Image currentImage;
    if (kIsWeb) {
      currentImage = Image.network(
        'assets/appimages/messier.png',
        repeat: ImageRepeat.repeatX,
      );
    } else {
      currentImage = Image(
          image: AssetImage('assets/appimages/messier.png'),
          repeat: ImageRepeat.repeatX,
          width: 10000);
    }
    return PageStructure(
        body: Center(
            child: Scaffold(
                body: Center(
                    child: Stack(alignment: Alignment.center, children: [
      Container(
          // Utiliser un container pour permettre à l'InteractiveViewer de prendre toute la place disponible
          width: double.infinity,
          height: double.infinity,
          child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(
                  double.infinity), // Marge autour de l'image
              
              minScale: 0.9, // Échelle minimale de zoom
              maxScale: 6.0, // Échelle maximale de zoom
              constrained: true,
              child: currentImage))
    ])))));
  }
}
