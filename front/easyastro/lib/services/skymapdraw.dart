import 'package:flutter/services.dart' show rootBundle;
import 'package:easyastro/astro/skymap.dart';
import 'dart:typed_data';
import 'package:easyastro/models/stars.dart';
import 'package:easyastro/models/constellations.dart';
import 'package:easyastro/models/dso.dart';
import 'dart:convert';

class SkyMapCreator {
  late Uint8List data;
  Function() callBack;

  SkyMapTransform skyMapTransform = SkyMapTransform();
  int _width;
  int _height;
  double maxMag;
  double lon;
  double lat;
  DateTime date;

  List<Star> skyMapPositions = [];
  List<Constellation> skyMapConstellationPositions = [];
  List<List<Map<String, dynamic>>> skyMapLines = [];
  List<DSO> DSOPosition = [];
  Observer observer = Observer();

  Future<void> _loadConfig(int width, int height, double maxMag, double lon,
      double lat, DateTime date, bool loadDSO) async {
    List<Star> starsCatalog = [];
    List<Constellation> constellationsCatalog = [];
    List<List<int>> constellationsLines = [];

    observer.setDate(date);
    observer.setLonDegrees(lon);
    observer.setLatDegrees(lat);

    var result = await rootBundle.loadString(
      "assets/astro/stars.json",
    );
    starsCatalog = Stars.fromJson(result).getStars();
    skyMapTransform.initStars(starsCatalog);

    for (final star in starsCatalog) {
      if (star.mag < maxMag) {
        skyMapTransform.skyposTransform(star, observer, width, height);
        if (star.visible) {
          skyMapPositions.add(star);
        }
      }
    }

    result = await rootBundle.loadString(
      "assets/astro/constellations.json",
    );
    constellationsCatalog = Constellations.fromJson(result).getConstellation();
    for (final constellation in constellationsCatalog) {
      skyMapTransform.skyposTransform(constellation, observer, width, height);

      if (constellation.visible) {
        constellation.name = constellation.name;
        constellation.abbrev = constellation.abbrev;
        skyMapConstellationPositions.add(constellation);
      }
    }

    result = await rootBundle.loadString(
      "assets/astro/constellationlines.json",
    );
    constellationsLines =
        ConstellationLines.fromJson(result).getConstellationLines();
    for (final line in constellationsLines) {
      var skyPos1 = starsCatalog[line[0]];
      var skyPos2 = starsCatalog[line[1]];

      if (skyPos1.visible && skyPos2.visible) {
        skyMapLines.add([skyPos1.pos, skyPos2.pos]);
      }
    }
    if (loadDSO) await loadDefaultDSO();
  }

  void clearDSO() {
    DSOPosition = [];
  }

  Future<void> loadDSO(List<DSO> dsos) async {
    print("Loading DSO");
    for (final dso in dsos) {
      skyMapTransform.skyposTransform(dso, observer, _width, _height);
      print("${dso.name}");
      if (dso.visible) DSOPosition.add(dso);
    }
  }

  Future<void> loadDefaultDSO() async {
    print("Loading default DSO");
    List<DSO> dsos = [];
    var result = await rootBundle.loadString(
      "assets/astro/dso.json",
    );
    List<dynamic> parsedJson = json.decode(result);
    for (final line in parsedJson) {
      Map<String, dynamic> pos = {
        "ra": line["pos"]["ra"],
        "dec": line["pos"]["dec"]
      };
      DSO dso =
          DSO(pos, line["name"], line["type"], line["phase"], line["color"]);
      dsos.add(dso);
    }
    await loadDSO(dsos);
  }

  List<Star> getStarsPosition() {
    return skyMapPositions;
  }

  List<Constellation> getConstellations() {
    return skyMapConstellationPositions;
  }

  List<List<Map<String, dynamic>>> getConstellationLines() {
    return skyMapLines;
  }

  List<DSO> getDSO() {
    return DSOPosition;
  }

  SkyMapCreator(this.callBack, this._width, this._height, this.maxMag, this.lon,
      this.lat, this.date);

  void loadConfig(bool loadDSO) {
    _loadConfig(_width, _height, maxMag, lon, lat, date, loadDSO).then((value) {
      callBack();
    });
  }
}
