import 'package:flutter/material.dart';
import 'package:easyastro/components/bottombar.dart'; 
import 'package:easyastro/components/pagestructure.dart';
import 'package:easyastro/models/catalogs.dart';
import 'package:easyastro/components/objectlist.dart';
import 'package:easyastro/components/objectbox.dart';
import 'package:easyastro/services/globals.dart';
import 'package:easyastro/components/rating.dart'; 
import 'package:easyastro/components/selectdate.dart'; 
import 'package:intl/intl.dart';
import 'package:easyastro/services/servicecheck.dart';
import 'package:easyastro/components/searchbar.dart';
import 'package:easyastro/components/filterbar.dart';

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
  Map<String, GlobalKey<RatingBoxState>> mappingRatingBox = {};

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
      Map<String,dynamic> newDate = await SelectDate.selectDate(context, _selectedDate, _selectedTime);
      if (newDate['nopickup']==false) {
        _selectedDate = newDate['date'];
        _selectedTime = newDate['time'];   
       _getNewCatalog();

      }
    }
        
  void update(int index, bool value){
    String objectName = _catalog[index].name;
    ObjectSelection().selection.firstWhere((k) => k.name == objectName ).selected=value;
    setState(() {
      _catalog[index].selected = value;
      mappingRatingBox[_catalog[index].name]?.currentState?.build(context);
     });

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
    mappingRatingBox.clear();
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
                                      GlobalKey<RatingBoxState> childKey = GlobalKey<RatingBoxState>();
                                      RatingBox rating = RatingBox(key: childKey, onValueChanged: update, index: index, initialValue:  _catalog[index].selected);
                                      mappingRatingBox[_catalog[index].name]=childKey;

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