import 'package:flutter/material.dart'; 
import 'package:front_test/components/pagestructure.dart';
import 'package:front_test/repositories/ObservableRepositories.dart';
import 'package:front_test/models/catalogs.dart';
import 'package:front_test/components/objectlist.dart';
import 'package:front_test/components/objectbox.dart';  
import 'package:front_test/services/globals.dart';


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
    }  
    
    update();
  }


  void update(){
    setState(() {
      _catalog = ObjectSelection().selection;
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
          return GestureDetector(
            child: ObjectBox(item: index, onValueChanged: update),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ObjectPage(item: index, onValueChanged: update),
                ),
              );
            },
          );
  
        }));
  }
}