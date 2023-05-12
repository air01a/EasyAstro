class ObservableObjects {
  List<ObservableObject> results = <ObservableObject>[];

  ObservableObjects();


  ObservableObjects.fromJson(List<dynamic> json) {
      if (json != null) {
        json.forEach((v) {
          results.add(ObservableObject.fromJson(v));
        });
      }
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
  int magnitude=10;

  double ra=0;
  double dec=0;
  String description='';
  String image='';
  bool selected = false;
  double meridian = 0;
  ObservableObject({required this.name, required this.ngc, required this.type, required this.season, required this.magnitude, required this.ra, required this.dec, required this.description, required this.image});

  ObservableObject.fromJson(Map<String, dynamic> json ) {
    name = json['NAME'] ?? 'N/A';

    ra = json['RA'] ?? 0;
    dec = json['DEC'] ?? 0;
    description = json['description'] ?? 'N/A';
    image = json['Image'] ?? '';
    magnitude = int.parse(json['Magnitude']);
    type = json['Object type'];
    meridian = json['meridian_time'];

  }

}
