import 'package:easyastro/models/catalogs.dart';
import 'package:easyastro/services/api.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:easyastro/repositories/ObservableRepositories.dart';
import 'package:easyastro/services/globals.dart';

class ServiceCheckHelper {
  static LocationData? locationData; 

  int getObjectIndex(String object){
    return ObjectSelection().selection.indexWhere((element) =>  element.name == object);
  }

  Future<void> updateAPILocation() async { 
    ApiBaseHelper helper = ApiBaseHelper();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd 23:mm').format(now);
    await helper.post("/planning/time",{"time": formattedDate});
    await helper.post("/planning",{"lon": locationData?.longitude, "lat":locationData?.latitude,"height": locationData?.altitude});
    
  }


  Future<void> changeObject(String object) async {
    ApiBaseHelper helper = ApiBaseHelper();
    ObservableObject obj = ObjectSelection().selection[getObjectIndex(object)];
    await helper.post("/telescope/goto/", {"ra":obj.ra, "dec":obj.dec});

  }


  Future<void> changeExposition(String exposition) async {
    ApiBaseHelper helper = ApiBaseHelper();
    await helper.post("/telescope/exposition", {"exposition":exposition});

  }


  Future<void> moveTelescope(double axis1, double axis2) async {
    ApiBaseHelper helper = ApiBaseHelper();
    print("Move");
    await helper.post("/telescope/move", {"axis1":axis1, "axis2":axis2});
    print("End of move");
  }

  Future<void> stackImage(String object) async {
    ApiBaseHelper helper = ApiBaseHelper();
    ObservableObject obj = ObjectSelection().selection[getObjectIndex(object)];
    await helper.post("/telescope/stacking/", {"ra":obj.ra, "dec":obj.dec});

  }

  Future<int> getDarkProgession() async {
    ApiBaseHelper helper = ApiBaseHelper();
    int ret = await helper.get("/telescope/get_dark_progress");
    return ret;
  }

  Future<void> updateTime(String time) async {
    ApiBaseHelper helper = ApiBaseHelper();
    //await helper.post("/planning/time",{"time": time});
    ObservableRepository catalog = ObservableRepository();
    
    ObjectSelection().selection = await catalog.fetchCatalogList(CurrentLocation().longitude, CurrentLocation().latitude, CurrentLocation().altitude, time);
  }


  Future<void> takeDark() async {
    ApiBaseHelper helper = ApiBaseHelper();
    await helper.get("/telescope/take_dark");
    
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
