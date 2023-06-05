import 'package:localstore/localstore.dart';

class SelectionStructure {
  final double hour;
  final String date;
  final double longitude;
  final double latitude;
  final double altitude;
  List<String> selected; 

  SelectionStructure({required this.date, required this.hour, required this.longitude, required this.latitude, required this.altitude, required this.selected});

  Map<String,dynamic> encode() {
    return {'hour':hour, 'date':date, 'longitude' : longitude, 'altitude': altitude, 'latitude': latitude, 'selection': selected};
  }
}

class LocalStorage {
  final db = Localstore.instance;
  final collectionName = 'selection';

  Future<Map<String, dynamic>?> getSelection(String? id) async { 
    return db.collection(collectionName).doc(id).get();
  }


  void deleteSelection(String? id) async {
    db.collection(collectionName).doc(id).delete();
  }

  void addSelection(SelectionStructure selection) async {
    final id = db.collection(collectionName).doc().id;
    // save the item  
    db.collection(collectionName).doc(id).set(selection.encode());
  }

  Future<Map<String, dynamic>?> getAllSelections() async {
    final items = await db.collection(collectionName).get();
    return items; 
  }
}