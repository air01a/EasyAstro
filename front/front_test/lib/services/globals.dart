import 'package:front_test/models/catalogs.dart'; 
import 'package:location/location.dart';


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

  factory ObjectSelection() {
    return _singleton;
  }

  ObjectSelection._internal();
}

class CurrentLocation {
  static final CurrentLocation _singleton = CurrentLocation._internal();
  LocationData? location;
  
  factory CurrentLocation() {
    return _singleton;
  }

  CurrentLocation._internal();
}


