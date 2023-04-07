import 'package:front_test/models/catalogs.dart';
import 'package:front_test/services/api.dart';


class ObservableRepository {
 ApiBaseHelper helper = ApiBaseHelper();

  Future<List<ObservableObject>> fetchCatalogList() async {
    final response = await helper.get("/planning/visible");
    String objects = "";

    response.map((line){
        objects += line[0] + ",";
    }).toList();
    final response2 = await helper.get("/planning/objects/$objects");

    return ObservableObjects.fromJson(response2).catalog;
  }
}
