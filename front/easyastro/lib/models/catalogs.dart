import 'package:easy_localization/easy_localization.dart';

class ObservableObjects {
  List<ObservableObject> results = <ObservableObject>[];

  ObservableObjects();

  static int getObjectIndex(String object, List<ObservableObject> catalog){
    return catalog.indexWhere((element) =>  element.name == object);
  }

  static ObservableObject getObjectWithIndex(String object, List<ObservableObject> catalog){
    return catalog[getObjectIndex(object, catalog)];
  }

  ObservableObjects.fromJson(List<dynamic> json) {
      
      json.forEach((v) {
        results.add(ObservableObject.fromJson(v));
      });
      
  }

  List<ObservableObject> get catalog {
    return results;
  }
}


class ObservableObject {
  String name='';
  String ngc='';
  String type='';
  String season='';
  double magnitude=10;
  double timeToMeridian = 0;
  double ra=0;
  double dec=0;
  String description='';
  String image='';
  bool selected = false;
  double meridian = 0;
  double rise = 0;
  double set = 0;
  double height = 0;
  bool visible=false;

  ObservableObject({required this.name, required this.ngc, required this.type, required this.season, required this.magnitude, required this.ra, required this.dec, required this.description, required this.image});

  ObservableObject.fromJson(Map<String, dynamic> json ) {

    name = json['NAME'] ?? 'N/A';

    ra = json['RA deg'] ?? 0;
    dec = json['DEC deg'] ?? 0;
    description = tr("_$name") ?? 'N/A';

    image = json['Image'] ?? '';
    if (json['Magnitude'] is String) {
      magnitude = double.parse(json['Magnitude']);
    } else {
      magnitude = json['Magnitude'] + 0.0;
    }
    type = json['Object type'];
    meridian = json['meridian_time'];
    rise = json['rise'] ?? -1;
    set = json['set'] ?? -1;
    meridian = json['meridian_time'] ?? -1;
    timeToMeridian=json['timeToMeridian'] ?? 0;
    height = json['height'];
    visible = json['visible'];
  }

}
