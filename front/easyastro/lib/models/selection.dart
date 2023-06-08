class SelectionStructure {
  final double hour;
  final String date;
  final double longitude;
  final double latitude;
  final double altitude;
  List<String> selected; 

  SelectionStructure({required this.date, required this.hour, required this.longitude, required this.latitude, required this.altitude, required this.selected});
  SelectionStructure.fromJson(Map<String, dynamic> json)
      : hour = json['hour'],
        date = json['date'],
        longitude = json['longitude'],
        latitude = json['latitude'],
        altitude = json['altitude'],
        selected = json['selected'];
        

  Map<String, dynamic> toJson() => {
        'hour': hour,
        'date': date,
        'longitude' : longitude,
        'latitude' : latitude,
        'altitude' : altitude,
        'selected' : selected
      };


}
