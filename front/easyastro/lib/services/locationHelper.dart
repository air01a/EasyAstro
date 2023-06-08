import 'package:easyastro/models/catalogs.dart';
import 'package:easyastro/services/api.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:easyastro/repositories/ObservableRepositories.dart';
import 'package:easyastro/services/globals.dart';

class LocationHelper {
  static LocationData? locationData; 




  Future<void> updateTime(String time) async {
    //await helper.post("/planning/time",{"time": time});
    ObservableRepository catalog = ObservableRepository();
    
    ObjectSelection().selection = await catalog.fetchCatalogList(CurrentLocation().location?.longitude, CurrentLocation().location?.latitude, CurrentLocation().location?.altitude, time);
  }
  

  Future<LocationData?> getLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    locationData = await location.getLocation();
    return locationData; 
  }
}
