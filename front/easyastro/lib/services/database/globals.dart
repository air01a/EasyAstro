import 'package:easyastro/models/catalogs.dart'; 
import 'package:easyastro/astro/astrocalc.dart';


class ServerInfo {
  static final ServerInfo _singleton = ServerInfo._internal();
  String host = '127.0.0.1:8000';
  bool connected = false;

  factory ServerInfo() {
    return _singleton;
  }

  ServerInfo._internal();
}


class ObjectSelection {
  static final ObjectSelection _singleton = ObjectSelection._internal();
  List<ObservableObject> selection =<ObservableObject>[];
  AstroCalc? astro;
  String? version; 

  factory ObjectSelection() {
    return _singleton;
  }

  ObjectSelection._internal();
}

class CurrentLocation {
  static final CurrentLocation _singleton = CurrentLocation._internal();
  bool isSetup=false;
  double? longitude=0;
  double? latitude=0;
  double? altitude=0;
  bool timeChanged=false; 
  
  factory CurrentLocation() {
    return _singleton;
  }

  CurrentLocation._internal();
}


