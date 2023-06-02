import 'package:flutter/material.dart';
import 'package:front_test/components/bottombar.dart'; 
import 'package:front_test/components/pagestructure.dart';
import 'package:front_test/models/catalogs.dart';
import 'package:front_test/components/objectlist.dart';
import 'package:front_test/components/objectbox.dart';
import 'package:front_test/services/globals.dart';
import 'package:front_test/components/rating.dart'; 
import 'package:intl/intl.dart';
import 'package:front_test/services/servicecheck.dart';
import 'package:front_test/components/searchbar.dart';
import 'package:front_test/components/filterbar.dart';

class ScreenObjectList extends StatefulWidget {
  @override
   _ScreenObjectList createState() => _ScreenObjectList();
}

class _ScreenObjectList extends State<ScreenObjectList> {
  List<ObservableObject> _catalog=[];
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  ServiceCheckHelper _checkHelper = ServiceCheckHelper();
  String searchValue = '';
  String filterValue = '';
  SearchField sf = SearchField();
  FilterField ff = FilterField();
  bool onlyVisible=true;

  void _getNewCatalog() {
    List<ObservableObject> temp = ObjectSelection().selection.toList();


    if (sf.isSearchActive) {
      temp = temp.where((object)=>object.name.toLowerCase().contains(searchValue.toLowerCase())).toList();
    } 

    if (ff.isFilterActive) {
      if (filterValue.toLowerCase()!='all') temp = temp.where((object)=>object.type.toLowerCase().contains(filterValue.toLowerCase())).toList();
      if (onlyVisible==true) temp = temp.where((object)=>object.visible==true).toList();
    } else {
      temp = temp.where((object)=>object.visible==true).toList();
    }

    setState(() {
      _catalog = temp;
    });

  }


  void search(String value) {
    searchValue = value;
    _getNewCatalog();
  }


  void filter(String? value, bool? visible) {
    if (value!=null) filterValue = value;
    if (visible!=null) onlyVisible = visible;
    _getNewCatalog();
  }



  void _search(BuildContext context) {
    sf.filterActivate();
    _getNewCatalog();
  }

  void _filter(BuildContext context) {
    ff.filterActivate();
    _getNewCatalog();
  }


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
    if (picked2 != null) {
      setState(() {

        _selectedTime = picked2;
      });
    } else {
      return; 
    }
    
    String hour = _selectedTime.hour.toString();if (hour.length==1)  hour = "0$hour";
    String min  = _selectedTime.minute.toString();if (min.length==1) min = "0$min";
    

    String newDate = "${DateFormat("yyyy-MM-dd").format(_selectedDate)} $hour:$min";
    await _checkHelper.updateTime(newDate);
    print("get new catalog $newDate");
    _getNewCatalog();
  }
    
  void update(int index, bool value){
    ObjectSelection().selection[index].selected = value;
    _getNewCatalog();
  }

  @override
  void initState() {
    super.initState();
    sf.setCallBack(search);
    ff.setCallBack(filter);
    _getNewCatalog();
  }

  @override
  Widget build(BuildContext context) {
    final bbar = BottomBar();

    bbar.addItem(const Icon(Icons.schedule), 'Change Date', _selectDate);
    bbar.addItem(const Icon(Icons.filter_alt), 'Filter', _filter);
    bbar.addItem(const Icon(Icons.search), 'Search', _search);
    return PageStructure(
            body: Container(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Column(
                          children: [
                          sf.buildSearchTextField(),
                          ff.buildFilterTextField(),
                          Expanded(
                              child: ListView.builder(
                                    itemCount: _catalog.length,
                                    itemBuilder: (context, index) {
                                      RatingBox rating = RatingBox(onValueChanged: update, index: index, initialValue: ObjectSelection().selection[index].selected);
                                     

                                      return GestureDetector(
                                        child: ObjectBox(object: _catalog[index], rating : rating),
                                        onTap: () {
                                          Navigator.push(
                                            
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ObjectPage(item: _catalog[index], rating: rating),
                                            ),
                                          );
                                          },
                                        onLongPress : () {
                                            Navigator.pushNamed(context, '/capture', arguments: {'object':_catalog[index].name});
                                          }
                                        
                                      );
                                    })
                          )
                    ]
            )),
        bottom : bbar
     
     
     );
  }
}