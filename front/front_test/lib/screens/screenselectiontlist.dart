import 'package:flutter/material.dart'; 
import 'package:front_test/components/pagestructure.dart';
import 'package:front_test/models/catalogs.dart';
import 'package:front_test/components/objectlist.dart';
import 'package:front_test/components/objectbox.dart';  
import 'package:front_test/services/globals.dart';
import 'package:front_test/components/rating.dart';
import 'package:front_test/services/servicecheck.dart'; 
import 'package:front_test/components/bottombar.dart'; 
import 'package:front_test/services/localstorage.dart';
import 'package:front_test/components/storeselection.dart';
import 'package:front_test/astro/astrocalc.dart';

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
      _catalog.sort((a, b) => a.timeToMeridian.compareTo(b.timeToMeridian));

    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
       _catalog = ObjectSelection().selection.where((line) => line.selected == true).toList();
       _catalog.sort((a, b) => a.timeToMeridian.compareTo(b.timeToMeridian));
    });
  }

  void callback(Map<String,dynamic> selection) {
    final ls = LocalStorage();
    setState( () {
          String newDate = "${selection!['date'].toString()} ${ConvertAngle.hourToString(selection['hour'])}";
          service.updateTime(newDate).then((value) {
            List<dynamic> selected = selection["selection"];
            selected.forEach((element) {
              ObjectSelection().selection.firstWhere((obj) => obj.name==element).selected=true;
            });
             _catalog  = ObjectSelection().selection.where((line) => line.selected == true).toList();
          });
        });

  }

  void _load(BuildContext context) {
    
     Navigator.push(                                 
          context,
          MaterialPageRoute(
            builder: (context) => LoadSelection(title:'Load planned selection', callback:callback),
          ),
        );
    
  }

  void _save(BuildContext context) {
    final ls = LocalStorage();
    List<String> selected = _catalog.map((object) => object.name).toList();
    String date =  ObjectSelection().astro!.getDate();
    double hour = ObjectSelection().astro!.hour;
    double longitude = ObjectSelection().astro!.longitude;
    double latitude = ObjectSelection().astro!.latitude;
    double altitude = ObjectSelection().astro!.altitude;
    
    SelectionStructure selection = SelectionStructure(altitude: altitude, date: date, hour: hour, longitude:longitude, latitude:latitude, selected: selected);
    ls.addSelection(selection);
  }

  @override
  Widget build(BuildContext context) {
 
    
    final bbar = BottomBar();

    bbar.addItem(const Icon(Icons.save), 'Save', _save);
    bbar.addItem(const Icon(Icons.download), 'Load', _load);

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
  
        }), bottom: bbar,);
  }
}