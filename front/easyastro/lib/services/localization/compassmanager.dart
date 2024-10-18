import 'package:flutter_compass/flutter_compass.dart';
import 'dart:async';

class CompassManager  {
  CompassEvent? lastRead;
  Function callBack; 
  StreamSubscription? _compassSubscription;


  CompassManager(this.callBack) {
    //_fetchPermissionStatus();
    _compassSubscription = FlutterCompass.events!.listen((event) {
      receiveEvent(event);
    });
  }


  Future<void> receiveEvent(CompassEvent event) async {
    final CompassEvent tmp = await FlutterCompass.events!.first;

    lastRead=tmp;

    int direction = 0;
    if (lastRead!=null && lastRead?.heading!=null && !lastRead!.heading!.isNaN) {
      direction=event.heading?.toInt() ?? 0;

    }
   await callBack(direction);
  }

  void quit() {
    _compassSubscription?.cancel();

  }

}