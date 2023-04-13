import 'package:flutter/material.dart'; 
import 'package:front_test/components/pagestructure.dart';
import 'package:front_test/models/catalogs.dart';
import 'package:front_test/components/objectlist.dart';
import 'package:front_test/components/objectbox.dart';
import 'package:front_test/services/globals.dart';
import 'package:front_test/components/rating.dart'; 
import 'package:intl/intl.dart';
import 'package:front_test/services/servicecheck.dart';


class ScreenObjectList extends StatefulWidget {
  @override
   _ScreenObjectList createState() => _ScreenObjectList();
}

class _ScreenObjectList extends State<ScreenObjectList> {
  List<ObservableObject> _catalog=[];
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  ServiceCheckHelper _checkHelper = ServiceCheckHelper();


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    } else {
      return; 
    }

    final TimeOfDay? picked2 = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked2 != null && picked2 != _selectedTime) {
      setState(() {
        _selectedTime = picked2;
      });
    } else {
      return; 
    }
    
    String newDate = "${DateFormat("yyyy-MM-dd").format(_selectedDate)} ${_selectedTime.hour}:${_selectedTime.minute}";
    _checkHelper.updateTime(newDate);

    setState(() {
      _catalog = ObjectSelection().selection;
    });
  }
    
  void update(int index, bool value){
    ObjectSelection().selection[index].selected = value;

    setState(() {
      _catalog  = ObjectSelection().selection;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _catalog  = ObjectSelection().selection;
    });

  }

  @override
  Widget build(BuildContext context) {
 

    return PageStructure(
        body: Container(
              padding: EdgeInsets.only(left: 8.0),
              child: Column(
                    children: [
                    ElevatedButton(
                                onPressed: () => _selectDate(context),
                                child: Text('Sélectionner une date'),
                              ),
                    Expanded(
                        child: ListView.builder(
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
                        
                              }
                            )
                    )
              ]
      )));
  }
}