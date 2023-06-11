import 'package:localstore/localstore.dart';


class LocalStorage {
  final db = Localstore.instance;
  final String collectionName;
  LocalStorage(this.collectionName); 


  Future<Map<String, dynamic>?> getSelection(String? id) async { 
    return db.collection(collectionName).doc(id).get();
  }


  void deleteSelection(String? id) async {
    db.collection(collectionName).doc(id).delete();
  }

  void addSelection(dynamic selection, {String? id}) async {
    id ??= db.collection(collectionName).doc().id;
    // save the item  
    db.collection(collectionName).doc(id).set(selection);
  }

  Future<Map<String, dynamic>?> getAllSelections() async {
    final items = await db.collection(collectionName).get();
    return items; 
  }
}