import 'package:front_test/models/catalogs.dart';
import 'package:front_test/services/api.dart';
import 'package:front_test/services/dbmanage.dart';

class ObservableRepository {

  Future<List<ObservableObject>> fetchCatalogList(double? lon, double? lat, double? alt, String? time) async {

    lon ??=0;
    lat ??=0;
    alt ??= 0;
 
    List<Map<String, dynamic>> response = await openCatalog(lon, lat, alt, time);
    return ObservableObjects.fromJson(response).catalog;
  }
}
