import 'dart:convert';
import 'package:easyastro/models/skyobject.dart';

class Stars {
  List<Star> _stars = [];

  Stars.fromJson(String contents) {
    final List<dynamic> jsonList = json.decode(contents);
    final List<Star> stars =
        jsonList.map((json) => Star.fromJson(json)).toList();
    _stars = stars;
  }

  List<Star> getStars() {
    return _stars;
  }
}

class Star extends SkyObject {
  double mag;
  double bv;
  int color = 0;
  double? radius;
  bool? bright;
  String name;

  Star({pos, required this.mag, required this.bv, required this.name})
      : super(pos);

  factory Star.fromJson(Map<String, dynamic> json) {
    return Star(
        pos: json['pos'],
        mag: json['mag'].toDouble(),
        bv: json['bv'].toDouble(),
        name: json['name']);
  }
}


/*
class StarNames {
  List<StarName> _starNames = [];

  StarNames.fromJson(String contents) {
    final List<dynamic> jsonList = json.decode(contents);
    final List<StarName> starNames =
        jsonList.map((json) => StarName.fromJson(json)).toList();
    _starNames = starNames;
  }

  List<StarName> getStarNames() {
    return _starNames;
  }
}

class StarName extends SkyObject {
  String label;

  StarName({pos, required this.label}) : super(pos);

  factory StarName.fromJson(Map<String, dynamic> json) {
    return StarName(
      pos: json['pos'],
      label: json['label'],
    );
  }
}*/
