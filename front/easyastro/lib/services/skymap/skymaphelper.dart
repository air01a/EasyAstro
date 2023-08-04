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
  double maxMag;
  double lon;
  double lat;
  DateTime date;

  List<Star> skyMapPositions = [];
  List<Constellation> skyMapConstellationPositions = [];
  List<List<Map<String, dynamic>>> skyMapLines = [];
  //List<StarName> skyMapStarNames = [];
  List<DSO> dsoPosition = [];
  Observer observer = Observer();
  List<Star> starsCatalog = [];
  List<List<int>> constellationsLines = [];

  void reloadStars() {
    skyMapPositions.clear();
    for (final star in starsCatalog) {
      if (star.mag < maxMag) {
        skyMapTransform.skyposTransform(star, observer, 1, 1);
        if (star.visible) {
          skyMapPositions.add(star);
        }
      }
    }

    skyMapLines.clear();
    for (final line in constellationsLines) {
      var skyPos1 = starsCatalog[line[0]];
      var skyPos2 = starsCatalog[line[1]];

      if (skyPos1.visible && skyPos2.visible) {
        skyMapLines.add([skyPos1.pos, skyPos2.pos]);
      }
    }
  }

  void changeMaxMag(double newMag) {
    maxMag = newMag;
  }

  Future<void> _loadConfig(double maxMag, double lon, double lat, DateTime date,
      bool loadDSO) async {
    List<Constellation> constellationsCatalog = [];

    starsCatalog = [];
    observer.setDate(date);
    observer.setLonDegrees(lon);
    observer.setLatDegrees(lat);

    var result = await rootBundle.loadString(
      "assets/astro/stars.json",
    );
    starsCatalog = Stars.fromJson(result).getStars();
    skyMapTransform.initStars(starsCatalog);
    result = await rootBundle.loadString(
      "assets/astro/constellationlines.json",
    );
    constellationsLines =
        ConstellationLines.fromJson(result).getConstellationLines();

    reloadStars();

    result = await rootBundle.loadString(
      "assets/astro/constellations.json",
    );
    constellationsCatalog = Constellations.fromJson(result).getConstellation();

    for (final constellation in constellationsCatalog) {
      skyMapTransform.skyposTransform(constellation, observer, 1, 1);

      if (constellation.visible) {
        constellation.name = constellation.name;
        constellation.abbrev = constellation.abbrev;
        skyMapConstellationPositions.add(constellation);
      }
    }

    if (loadDSO) await loadDefaultDSO();
  }

  void clearDSO() {
    dsoPosition = [];
  }

  Future<void> loadDSO(List<DSO> dsos) async {
    dsoPosition.clear();
    for (final dso in dsos) {
      skyMapTransform.skyposTransform(dso, observer, 1, 1);
      if (dso.visible) dsoPosition.add(dso);
    }
  }

  Future<void> loadDefaultDSO() async {
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
    return dsoPosition;
  }

  SkyMapCreator(this.callBack, this.maxMag, this.lon, this.lat, this.date);

  void loadConfig(bool loadDSO) {
    _loadConfig(maxMag, lon, lat, date, loadDSO).then((value) {
      callBack();
    });
  }
}
