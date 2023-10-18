import 'dart:math';

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
  const ScreenMap({key}) : super(key: key);
  @override
  State<ScreenMap> createState() => _ScreenMap();
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
  String? highlightObject;
  double _rotation = 0;
  final GlobalKey _viewerKey = GlobalKey();

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
        if (highlightObject == null) {
          temp = ObjectSelection()
              .selection
              .where((line) =>
                  (line.selected == true) ||
                  (line.name == 'Moon') ||
                  (line.type == 'planet') ||
                  (line.type == 'star'))
              .toList();
        } else {
          temp = ObjectSelection()
              .selection
              .where((line) =>
                  (line.name == highlightObject) ||
                  (line.name == 'Moon') ||
                  (line.type == 'planet') ||
                  (line.type == 'star'))
              .toList();
        }
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
      if (object.name == highlightObject) color = 0x0;
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

  void changeRotation(double rotation) {
    double rad = rotation * pi / 180;

    var array =
        _transformationController.value.applyToVector3Array([0, 0, 0, 1, 0, 0]);
    Offset delta = Offset(array[3] - array[0], array[4] - array[1]);
    double currentRotation = delta.direction;
    if (currentRotation < 0) currentRotation = 2 * pi + currentRotation;
    rad = rad - currentRotation;
    var c = cos(rad);
    var s = sin(rad);

    double focalPointX = skyMapSize / 2;
    double focalPointY = skyMapSize / 2;
    var dx = (1 - c) * focalPointX + s * focalPointY;
    var dy = (1 - c) * focalPointY - s * focalPointX;

    Matrix4 matrix = Matrix4(c, s, 0, 0, -s, c, 0, 0, 0, 0, 1, 0, dx, dy, 0, 1);

    setState(() {
      _transformationController.value *= matrix;
    });
  }

  Widget buildMenu() {
    return Positioned(
      top: 100, // Ajustez cette valeur pour positionner le menu correctement
      left: 20, // Ajustez cette valeur pour positionner le menu correctement
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 2500),
        width: 200, // Ajustez cette valeur pour régler la largeur du menu
        height: 400, // Ajustez cette valeur pour régler la hauteur du menu
        color: Colors.blue,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text('mag').tr(),
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
              title: const Text('map_show_lines').tr(),
            ),
            CheckboxListTile(
              value: showStarsName,
              onChanged: (bool? value) {
                setState(() {
                  showStarsName = value!;
                  changeStarName();
                });
              },
              title: const Text('map_show_starname').tr(),
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
              title: const Text('dso').tr(),
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
              title: const Text('only_selected').tr(),
            ),
            const Text('rotation').tr(),
            SfLinearGauge(
              maximum: 359,
              minimum: 0,
              orientation: LinearGaugeOrientation.horizontal,
              markerPointers: [
                LinearShapePointer(
                  value: _rotation,
                  height: 25,
                  width: 25,
                  shapeType: LinearShapePointerType.invertedTriangle,
                  dragBehavior: LinearMarkerDragBehavior.free,
                  onChangeEnd: (value) => {changeRotation(_rotation)},
                  onChanged: (double newValue) {
                    setState(() {
                      _rotation = newValue;
                    });
                  },
                ),
              ],
              barPointers: [LinearBarPointer(value: maxMag)],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    showDso = ConfigManager().configuration?["mapShowDSO"]?.value;
    showOnlySelected =
        ConfigManager().configuration?["mapShowOnlySelected"]?.value;
    showConstellation = ConfigManager().configuration?["mapShowLines"]?.value;
    showStarsName = ConfigManager().configuration?["mapShowStarNames"]?.value;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null) {
      final Map<String, dynamic> args = arguments as Map<String, String>;
      if (args.containsKey('selectedObject')) {
        highlightObject = args['selectedObject'];
      }
      showOnlySelected = true;
      showDso = true;
    }

    loadDSO();

    skyMap = SkyMap(astro!.longitude, astro!.latitude, astro!.getDateTime(),
        customDSO: dsoList,
        loadDSO: false,
        showLines: showConstellation,
        showStarNames: showStarsName,
        size: skyMapSize);
    maxMag = 5;
    var size = MediaQuery.of(context).size;
    double minSize = size.width;
    if (size.height < size.width) {
      minSize = size.height;
    }
    final zoomFactor = minSize / skyMapSize;

    _transformationController.value.setEntry(0, 0, zoomFactor);
    _transformationController.value.setEntry(1, 1, zoomFactor);
    _transformationController.value.setEntry(2, 2, zoomFactor);
    //_transformationController.value.setEntry(0, 3, xTranslate);
    //_transformationController.value.setEntry(1, 3, yTranslate);
    //_transformationController.value.setEntry(0, 3, zoomFactor * skyMapSize / 2);
    //_transformationController.value.setEntry(1, 3, zoomFactor * skyMapSize / 2);
    changeRotation(_rotation);
  }

  @override
  Widget build(BuildContext context) {
    return PageStructure(
        body: Center(
            child: Scaffold(
                body: Center(
                    child: Stack(children: [
          InteractiveViewer(
              key: _viewerKey,
              transformationController: _transformationController,
              boundaryMargin: const EdgeInsets.all(
                  double.infinity), // Marge autour de l'image
              minScale: 0.1, // Échelle minimale de zoom
              maxScale: 4.0, // Échelle maximale de zoom
              constrained: false,
              child: skyMap!),
          if (_isMenuOpen) buildMenu(),
          if (highlightObject == null)
            Positioned(
              top: 0,
              left: 0,
              height: 48,
              child: GestureDetector(
                  onTap: () => {
                        setState(() {
                          _isMenuOpen = !_isMenuOpen;
                        })
                      }, //skyMap!.setMaxMagnitude(10)},
                  child: const Icon(Icons.settings, size: 48.0)),
            ),
          Positioned(
              top: 12,
              left: 48,
              //  right: 0,
              child: Center(child: Text(astro!.getDateTimeString())))
        ])))),
        showDrawer: (highlightObject == null),
        title: "skymap".tr());
  }
}
