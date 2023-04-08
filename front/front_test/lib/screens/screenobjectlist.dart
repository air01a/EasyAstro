import 'package:flutter/material.dart'; 
import 'package:front_test/components/pagestructure.dart';
import 'package:front_test/repositories/ObservableRepositories.dart';
import 'package:front_test/models/catalogs.dart';
import 'package:front_test/components/objectlist.dart';
import 'package:front_test/components/objectbox.dart';  
import 'package:front_test/services/globals.dart';
import 'package:front_test/components/rating.dart'; 


class ScreenObjectList extends StatefulWidget {
  @override
   _ScreenObjectList createState() => _ScreenObjectList();
}

class _ScreenObjectList extends State<ScreenObjectList> {
  List<ObservableObject> _catalog = <ObservableObject>[];
  
  
  Future<void> getData() async {
    if (ObjectSelection().selection.isEmpty) {
      final jsonData = await ObservableRepository().fetchCatalogList() ;
      ObjectSelection().selection = jsonData;
      setState(() {
       _catalog = jsonData;
        });
     }
    }  
    

  


  void update(int index, bool value){
    ObjectSelection().selection[index].selected = value;

    setState(() {
      _catalog[index].selected = value;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return PageStructure(body: ListView.builder(
        itemCount: _catalog.length,
        itemBuilder: (context, index) {
          RatingBox rating = RatingBox(onValueChanged: update, index: index, initialValue: ObjectSelection().selection[index].selected);
          return GestureDetector(
            child: ObjectBox(item: index, rating : rating), //, onValueChanged: update),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ObjectPage(item: index, rating: rating),
                ),
              );
            },
          );
  
        }));
  }
}