import 'package:flutter/material.dart';
import 'package:easyastro/components/structure/pagestructure.dart';
import 'package:easyastro/components/skymap.dart';
import 'package:easyastro/services/database/globals.dart';
import 'package:easyastro/models/catalogs.dart';
import 'package:easyastro/models/dso.dart';
import 'package:easyastro/astro/astrocalc.dart';
import 'package:easyastro/services/database/configmanager.dart';

class ScreenMap extends StatefulWidget {
  @override
  _ScreenMap createState() => _ScreenMap();
}

class _ScreenMap extends State<ScreenMap> {
  final viewTransformationController = TransformationController();
  List<DSO> dsoList = [];
  AstroCalc? astro = ObjectSelection().astro;
  SkyMap? skyMap;
  late bool showDso;
  late bool showOnlySelected;

  int getPlanetColor(String name) {
    switch (name) {
      case 'Mars':
        {
          return 0xFFFF5733;
        }
      case 'Jupiter':
        {
          return 0xFFFFD700;
        }
      case 'Saturn':
        {
          return 0xFFFFD700;
        }
      case 'Venus':
        {
          return 0xFFFFC300;
        }
    }
    return 0xFFFFFFFF;
  }

  void loadDSO() {
    int type;
    int color;
    List<ObservableObject> temp;
    if (showDso) {
      if (showOnlySelected) {
        temp = ObjectSelection()
            .selection
            .where((line) =>
                (line.selected == true) ||
                (line.name == 'Moon') ||
                (line.type == 'planet') ||
                (line.type == 'star'))
            .toList();
      } else {
        temp = ObjectSelection().selection.toList();
      }
    } else {
      temp = ObjectSelection()
          .selection
          .where((line) =>
              (line.selected == true) ||
              (line.name == 'Moon') ||
              (line.type == 'planet') ||
              (line.type == 'star'))
          .toList();
    }
    dsoList = [];
    for (final object in temp) {
      Map<String, dynamic> pos = {
        'ra': object.ra * 0.0174532925199,
        'dec': object.dec * 0.0174532925199
      };
      switch (object.type) {
        case 'star':
          {
            type = 11;
            color = 0xFFFFFFFF;
          }
          break;
        case 'satellite':
          {
            type = 11;
            color = 0xFFFFFFFF;
          }
          break;
        case 'planet':
          {
            type = 10;
            color = getPlanetColor(object.name);
          }
          break;
        default:
          {
            type = 1;
            color = 4294967040;
          }
      }
      ;
      DSO dso = DSO(pos, object.name, type, 0, color);
      dsoList.add(dso);
    }
  }

  void changeConstellation() {
    skyMap!.showConstellation(!skyMap!.showLines);
    skyMap!.reload();
  }

  void changeDso() {
    showDso = !showDso;
    loadDSO();
    skyMap!.reloadDSO(dsoList);
  }

  @override
  void initState() {
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

    showDso = ConfigManager().configuration?["mapShowDSO"]?.value;
    showOnlySelected =
        ConfigManager().configuration?["mapShowOnlySelected"]?.value;
    loadDSO();
    skyMap = SkyMap(astro!.longitude, astro!.latitude, astro!.getDateTime(),
        customDSO: dsoList,
        loadDSO: false,
        showLines: ConfigManager().configuration?["mapShowLines"]?.value);
  }

  @override
  Widget build(BuildContext context) {
    return PageStructure(
        body: Center(
            child: Scaffold(
                body: Center(
                    child: Stack(children: [
      InteractiveViewer(
          boundaryMargin:
              const EdgeInsets.all(double.infinity), // Marge autour de l'image
          minScale: 0.3, // Échelle minimale de zoom
          maxScale: 4.0, // Échelle maximale de zoom
          constrained: false,
          child: skyMap!),
      Positioned(
        top: 0,
        left: 0,
        child: GestureDetector(
            onTap: () => {skyMap!.setMaxMagnitude(10)},
            child: Icon(Icons.access_alarm)),
      ),
      Positioned(
        top: 20,
        left: 0,
        child: GestureDetector(
            onTap: () => {changeConstellation()},
            child: Icon(Icons.access_alarm)),
      ),
      Positioned(
        top: 30,
        left: 0,
        child: GestureDetector(
            onTap: () => {changeDso()}, child: Icon(Icons.access_alarm)),
      )
    ])))));
  }
}
