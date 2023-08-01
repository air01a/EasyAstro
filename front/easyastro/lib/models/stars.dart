import 'dart:convert';
import 'dart:io';
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

  Star({pos, required this.mag, required this.bv}) : super(pos);

  factory Star.fromJson(Map<String, dynamic> json) {
    return Star(
        pos: json['pos'],
        mag: json['mag'].toDouble(),
        bv: json['bv'].toDouble());
  }
}
