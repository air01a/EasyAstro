import 'dart:convert';
import 'package:easyastro/models/skyobject.dart';

class Constellations {
  List<Constellation> _constellation = [];

  Constellations.fromJson(String contents) {
    final List<dynamic> jsonList = json.decode(contents);
    final List<Constellation> stars =
        jsonList.map((json) => Constellation.fromJson(json)).toList();
    _constellation = stars;
  }

  List<Constellation> getConstellation() {
    return _constellation;
  }
}

class Constellation extends SkyObject {
  String abbrev;
  String name;

  Constellation({pos, required this.abbrev, required this.name}) : super(pos);

  factory Constellation.fromJson(Map<String, dynamic> json) {
    return Constellation(
        pos: json['pos'], abbrev: json['abbrev'], name: json['name']);
  }
}

class ConstellationLines {
  List<List<int>> _constellationLines = [];

  ConstellationLines.fromJson(String contents) {
    final List<dynamic> jsonList = json.decode(contents);
    final List<List<int>> constellationLines =
        jsonList.map((json) => List<int>.from(json)).toList();
    _constellationLines = constellationLines;
  }

  List<List<int>> getConstellationLines() {
    return _constellationLines;
  }
}
