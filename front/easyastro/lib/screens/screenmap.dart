import 'package:flutter/material.dart';
import 'package:easyastro/components/structure/pagestructure.dart';
import 'package:easyastro/components/elements/skymap.dart';
import 'package:easyastro/services/database/globals.dart';
import 'package:easyastro/models/catalogs.dart';
import 'package:easyastro/models/dso.dart';
import 'package:easyastro/astro/astrocalc.dart';
import 'package:easyastro/services/database/configmanager.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:easy_localization/easy_localization.dart';

class ScreenMap extends StatefulWidget {
  @override
  _ScreenMap createState() => _ScreenMap();
}

class _ScreenMap extends State<ScreenMap> {
  final _transformationController = TransformationController();
  List<DSO> dsoList = [];
  AstroCalc? astro = ObjectSelection().astro;
  SkyMap? skyMap;
  late bool showDso;
  late bool showOnlySelected;
  late bool showStarsName;
  bool _isMenuOpen = false;
  late double maxMag;
  late bool showConstellation;
  double skyMapSize = 1400;

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
    skyMap!.showConstellation(showConstellation);
    skyMap!.reload();
  }

  void changeDso() {
    //showDso = !showDso;
    loadDSO();
    skyMap!.reloadDSO(dsoList);
  }

  void changeStarName() {
    skyMap!.showStarsNames(showStarsName);
  }

  Widget buildMenu() {
    return Positioned(
      top: 100, // Ajustez cette valeur pour positionner le menu correctement
      left: 20, // Ajustez cette valeur pour positionner le menu correctement
      child: AnimatedContainer(
        duration: Duration(milliseconds: 2500),
        width: 200, // Ajustez cette valeur pour régler la largeur du menu
        height: 400, // Ajustez cette valeur pour régler la hauteur du menu
        color: Colors.blue,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('mag').tr(),
            SfLinearGauge(
              maximum: 8,
              minimum: 0,
              orientation: LinearGaugeOrientation.horizontal,
              markerPointers: [
                LinearShapePointer(
                  value: maxMag,
                  height: 25,
                  width: 25,
                  shapeType: LinearShapePointerType.invertedTriangle,
                  dragBehavior: LinearMarkerDragBehavior.free,
                  onChangeEnd: (value) => {skyMap!.setMaxMagnitude(maxMag)},
                  onChanged: (double newValue) {
                    setState(() {
                      maxMag = newValue;
                    });
                  },
                ),
              ],
              barPointers: [LinearBarPointer(value: maxMag)],
            ),
            CheckboxListTile(
              value: showConstellation,
              onChanged: (bool? value) {
                setState(() {
                  showConstellation = value!;
                  changeConstellation();
                });
              },
              title: Text('map_show_lines').tr(),
            ),
            CheckboxListTile(
              value: showStarsName,
              onChanged: (bool? value) {
                setState(() {
                  showStarsName = value!;
                  changeStarName();
                });
              },
              title: Text('map_show_starname').tr(),
            ),
            // Ajoutez votre jauge ici, par exemple : LinearProgressIndicator()
            CheckboxListTile(
              value: showDso,
              onChanged: (bool? value) {
                setState(() {
                  showDso = value!;
                  if (!showDso) showOnlySelected = false;
                  changeDso();
                });
              },
              title: Text('dso').tr(),
            ),
            CheckboxListTile(
              value: showOnlySelected,
              onChanged: (bool? value) {
                setState(() {
                  showOnlySelected = value!;
                  if (value) showDso = true;
                  changeDso();
                });
              },
              title: Text('only_selected').tr(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    //viewTransformationController.value = Matrix4.diagonal3Values(4.0, 4.0, 1.0);

    showDso = ConfigManager().configuration?["mapShowDSO"]?.value;
    showOnlySelected =
        ConfigManager().configuration?["mapShowOnlySelected"]?.value;
    showConstellation = ConfigManager().configuration?["mapShowLines"]?.value;
    showStarsName = ConfigManager().configuration?["mapShowStarNames"]?.value;
    loadDSO();
    skyMap = SkyMap(astro!.longitude, astro!.latitude, astro!.getDateTime(),
        customDSO: dsoList,
        loadDSO: false,
        showLines: showConstellation,
        showStarNames: showStarsName,
        size: skyMapSize);
    maxMag = 5;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var size = MediaQuery.of(context).size;
    double minSize = size.width;
    if (size.height < size.width) {
      minSize = size.height;
    }
    final zoomFactor = minSize / skyMapSize;
    final xTranslate = size.width / 2 - zoomFactor * skyMapSize / 2;

    final yTranslate = 0.0; //-(size.height * zoomFactor) / 2;
    _transformationController.value.setEntry(0, 0, zoomFactor);
    _transformationController.value.setEntry(1, 1, zoomFactor);
    _transformationController.value.setEntry(2, 2, zoomFactor);
    _transformationController.value.setEntry(0, 3, xTranslate);
    _transformationController.value.setEntry(1, 3, -yTranslate);
  }

  @override
  Widget build(BuildContext context) {
    return PageStructure(
        body: Center(
            child: Scaffold(
                body: Center(
                    child: Stack(children: [
      InteractiveViewer(
          transformationController: _transformationController,
          boundaryMargin:
              const EdgeInsets.all(double.infinity), // Marge autour de l'image
          minScale: 0.3, // Échelle minimale de zoom
          maxScale: 4.0, // Échelle maximale de zoom
          constrained: false,
          child: skyMap!),
      if (_isMenuOpen) buildMenu(),
      Positioned(
        top: 0,
        left: 0,
        height: 30,
        child: GestureDetector(
            onTap: () => {
                  setState(() {
                    _isMenuOpen = !_isMenuOpen;
                  })
                }, //skyMap!.setMaxMagnitude(10)},
            child: Icon(Icons.settings, size: 48.0)),
      ),
      Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Center(child: Text(astro!.getDateTimeString())))
    ])))));
  }
}
