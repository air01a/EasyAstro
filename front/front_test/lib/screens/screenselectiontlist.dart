import 'package:flutter/material.dart'; 
import 'package:front_test/components/pagestructure.dart';
import 'package:front_test/repositories/ObservableRepositories.dart';
import 'package:front_test/models/catalogs.dart';
import 'package:front_test/components/objectlist.dart';
import 'package:front_test/components/objectbox.dart';  
import 'package:front_test/services/globals.dart';
import 'package:front_test/components/rating.dart'; 


class ScreenSelectionList extends StatefulWidget {
  @override
   _ScreenSelectionList createState() => _ScreenSelectionList();
}

class _ScreenSelectionList extends State<ScreenSelectionList> {
  List<ObservableObject> _catalog = <ObservableObject>[];

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }
    
  void update(int index, bool value){
    ObjectSelection().selection[index].selected = value;

    setState(() {
      _catalog  = ObjectSelection().selection.where((line) => line.selected == true).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _catalog = ObjectSelection().selection.where((line) => line.selected == true).toList();

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

           onLongPress : () {
              Navigator.pushNamed(context, '/capture', arguments: {'object':ObjectSelection().selection[index].name});
            }
          );
  
        }));
  }
}