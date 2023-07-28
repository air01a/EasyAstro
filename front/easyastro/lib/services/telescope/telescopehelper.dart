import 'package:easyastro/services/network/api.dart';
import 'package:easyastro/services/database/globals.dart';
import 'package:intl/intl.dart';
import 'package:easyastro/models/catalogs.dart';
import 'dart:convert';
import 'package:easyastro/models/telescopestatus.dart';

class TelescopeHelper {
  final ApiBaseHelper helper = ApiBaseHelper();
  final String server;

  TelescopeHelper(this.server);

  Future<void> updateAPILocation() async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd 23:mm').format(now);
    await helper.post(server, "/telescope/time", {"time": formattedDate});
    if (helper.lastError == 0) {
      await helper.post(server, "/telescope/location", {
        "lon": CurrentLocation().longitude,
        "lat": CurrentLocation().latitude,
        "height": CurrentLocation().altitude
      });
    }
  }

  Future<void> changeObject(String object) async {
    ObservableObject? obj = ObservableObjects.getObjectWithIndex(
        object, ObjectSelection().selection);
    if (obj != null)
      await helper.post(server, "/telescope/goto",
          {"ra": obj.ra, "dec": obj.dec, "object": obj.name});
  }

  Future<void> changeExposition(double exposition, int gain) async {
    await helper.post(server, "/telescope/exposition",
        {"exposition": exposition + 0.0, "gain": gain});
  }

  Future<void> moveTelescope(double axis1, double axis2) async {
    await helper
        .post(server, "/telescope/move", {"axis1": axis1, "axis2": axis2});
  }

  Future<void> stackImage(String object) async {
    ObservableObject? obj = ObservableObjects.getObjectWithIndex(
        object, ObjectSelection().selection);
    if (obj != null)
      await helper.post(server, "/telescope/stacking",
          {"ra": obj.ra, "dec": obj.dec, "object": object});
  }

  Future<void> stopStacking(String object) async {
    await helper.post(server, "/telescope/stop_stacking", {});
  }

  Future<void> stopTelescope() async {
    await helper.get(server, "/stop");
  }

  Future<int> getDarkProgession() async {
    int ret = await helper.get(server, "/telescope/get_dark_progress");
    return ret;
  }

  Future<void> takeDark() async {
    await helper.get(server, "/telescope/take_dark");
  }

  Future<List<dynamic>> getDarkLibrary() async {
    List<dynamic> ret =
        await helper.get(server, "/telescope/get_darks_library");
    return ret;
  }

  Future<String> getCurrentLibrary() async {
    String ret = await helper.get(server, "/telescope/get_current_dark");
    return ret;
  }

  Future<void> changeDark(String dark) async {
    await helper.post(server, "/telescope/current_dark", {"path": dark});
  }

  Future<TelescopeStatus> getCurrentObject() async {
    TelescopeStatus telescopeStatus =
        TelescopeStatus.fromJson(await helper.get(server, "/telescope/status"));
    return telescopeStatus;
  }
}
