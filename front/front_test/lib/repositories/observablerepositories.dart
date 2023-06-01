import 'package:front_test/models/catalogs.dart';
import 'package:front_test/services/api.dart';
import 'package:front_test/services/dbmanage.dart';

class ObservableRepository {
 ApiBaseHelper helper = ApiBaseHelper();

  Future<List<ObservableObject>> fetchCatalogList(double? lon, double? lat, double? alt, String? time) async {

    lon ??=0;
    lat ??=0;
    alt ??= 0;
    //final response = await helper.get("/planning/visible");
    //String objects = "";

    //response.map((line){
    //    objects += line[0] + ",";
    //}).toList();
    //final response2 = await helper.get("/planning/objects/$objects");
    List<Map<String, dynamic>> response = await openCatalog(lon, lat, alt, time);
    return ObservableObjects.fromJson(response).catalog;
  }
}
