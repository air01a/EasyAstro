import 'package:easyastro/services/network/api.dart';
import 'package:easyastro/services/database/globals.dart';
import 'package:intl/intl.dart';
import 'package:easyastro/models/catalogs.dart';

class TelescopeHelper {
  final ApiBaseHelper helper = ApiBaseHelper();
  final String server; 

  TelescopeHelper(this.server);


  Future<void> updateAPILocation() async { 
    ApiBaseHelper helper = ApiBaseHelper();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd 23:mm').format(now);
    await helper.post(server,"/planning/time",{"time": formattedDate});
    await helper.post(server, "/planning",{"lon": CurrentLocation().longitude, "lat":CurrentLocation().latitude,"height": CurrentLocation().altitude});
    
  }


  Future<void> changeObject(String object) async {
    ApiBaseHelper helper = ApiBaseHelper();
    ObservableObject? obj = ObservableObjects.getObjectWithIndex(object, ObjectSelection().selection);
    if (obj!=null) await helper.post(server, "/telescope/goto/", {"ra":obj.ra, "dec":obj.dec, "object":obj.name});

  }


  Future<void> changeExposition(String exposition) async {
    ApiBaseHelper helper = ApiBaseHelper();
    await helper.post(server, "/telescope/exposition", {"exposition":exposition});

  }


  Future<void> moveTelescope(double axis1, double axis2) async {
    ApiBaseHelper helper = ApiBaseHelper();
    await helper.post(server, "/telescope/move", {"axis1":axis1, "axis2":axis2});
  }

  Future<void> stackImage(String object) async {
    ApiBaseHelper helper = ApiBaseHelper();
    ObservableObject? obj = ObservableObjects.getObjectWithIndex(object, ObjectSelection().selection);
    if (obj!=null) await helper.post(server, "/telescope/stacking/", {"ra":obj.ra, "dec":obj.dec, "object": object});

  }

  Future<int> getDarkProgession() async {
    ApiBaseHelper helper = ApiBaseHelper();
    int ret = await helper.get(server, "/telescope/get_dark_progress");
    return ret;
  }

  Future<void> takeDark() async {
    ApiBaseHelper helper = ApiBaseHelper();
    await helper.get(server, "/telescope/take_dark");
    
  }

  Future<String> getCurrentObject() async {
    ApiBaseHelper helper = ApiBaseHelper();
    String object = await helper.get(server, "/telescope/operation");
    return object;
    
  }

}