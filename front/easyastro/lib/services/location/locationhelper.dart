import 'package:easyastro/repositories/observablerepositories.dart';
import 'package:easyastro/services/database/globals.dart';
import 'package:geolocator/geolocator.dart';

class LocationHelper {
  static Position? locationData;

  Future<void> updateTime(String time, {bool changeDate = true}) async {
    //await helper.post("/planning/time",{"time": time});
    ObservableRepository catalog = ObservableRepository();
    CurrentLocation().timeChanged = changeDate;
    ObjectSelection().selection = await catalog.fetchCatalogList(
        CurrentLocation().longitude,
        CurrentLocation().latitude,
        CurrentLocation().altitude,
        time);
  }

  Future<Position> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }
    print("location enabled");
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      print("asking for permission");
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition();
    return position;
  }
}
