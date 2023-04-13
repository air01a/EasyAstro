import 'package:front_test/services/api.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:front_test/repositories/ObservableRepositories.dart';
import 'package:front_test/services/globals.dart';

class ServiceCheckHelper {
  LocationData? locationData; 


  Future<void> updateAPILocation() async { 
    ApiBaseHelper helper = ApiBaseHelper();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd 23:mm').format(now);
    await helper.post("/planning/time",{"time": formattedDate});
    await helper.post("/planning",{"lon": locationData?.longitude, "lat":locationData?.latitude,"height": locationData?.altitude});
    
  }


  Future<void> updateTime(String time) async {
    ApiBaseHelper helper = ApiBaseHelper();
    await helper.post("/planning/time",{"time": time});
    ObservableRepository catalog = ObservableRepository();
    ObjectSelection().selection = await catalog.fetchCatalogList();
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
