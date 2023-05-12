import 'package:flutter/material.dart'; 
import 'package:front_test/components/pagestructure.dart';
import 'package:front_test/models/catalogs.dart';
import 'package:front_test/components/objectlist.dart';
import 'package:front_test/components/objectbox.dart';  
import 'package:front_test/services/globals.dart';
import 'package:front_test/components/rating.dart';
import 'package:front_test/services/servicecheck.dart'; 


class ScreenSelectionList extends StatefulWidget {
  @override
   _ScreenSelectionList createState() => _ScreenSelectionList();
}

class _ScreenSelectionList extends State<ScreenSelectionList> {
  List<ObservableObject> _catalog = <ObservableObject>[];
  final service = ServiceCheckHelper();
  
  void update(int index, bool value){
    
    ObjectSelection().selection[service.getObjectIndex(_catalog[index].name)].selected = value;

    setState(() {
      _catalog  = ObjectSelection().selection.where((line) => line.selected == true).toList();
      _catalog.sort((a, b) => a.meridian.compareTo(b.meridian));

    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
       _catalog = ObjectSelection().selection.where((line) => line.selected == true).toList();
       _catalog.sort((a, b) => a.meridian.compareTo(b.meridian));
    });
  }

  @override
  Widget build(BuildContext context) {
 

    return PageStructure(body: ListView.builder(
        itemCount: _catalog.length,
        itemBuilder: (context, index) {
          RatingBox rating = RatingBox(onValueChanged: update, index: index, initialValue: _catalog[index].selected);
          return GestureDetector(
            child: ObjectBox(object : _catalog[index],  rating : rating), //, onValueChanged: update),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ObjectPage(item: _catalog[index], rating: rating),
                ),
              );
            },

           onLongPress : () {
              Navigator.pushNamed(context, '/capture', arguments: {'object':ObjectSelection().selection[index].name});
            }
          );
  
        }));
  }
}