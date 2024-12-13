import 'package:flutter/material.dart';
import 'package:easyastro/components/structure/bottombar.dart';
import 'package:easyastro/components/structure/pagestructure.dart';
import 'package:easyastro/models/catalogs.dart';
import 'package:easyastro/components/elements/objectlist.dart';
import 'package:easyastro/components/elements/objectbox.dart';
import 'package:easyastro/services/database/globals.dart';
import 'package:easyastro/components/elements/rating.dart';
import 'package:easyastro/components/forms/selectdate.dart';
import 'package:easyastro/components/forms/searchbar.dart';
import 'package:easyastro/components/forms/filterbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:async';

class ScreenObjectList extends StatefulWidget {
  const ScreenObjectList({super.key});

  @override
  State<ScreenObjectList> createState() => _ScreenObjectList();
}

class _ScreenObjectList extends State<ScreenObjectList> {
  List<ObservableObject> _catalog = [];
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String searchValue = '';
  String filterValue = 'all';
  SearchField sf = SearchField();
  FilterField ff = FilterField();
  bool onlyVisible = true;
  Map<String, GlobalKey<RatingBoxState>> mappingRatingBox = {};
  final bbar = BottomBar();
  late Timer timer;

  void _getNewCatalog() {
    List<ObservableObject> temp = ObjectSelection().selection.toList();

    if (sf.isSearchActive) {
      temp = temp
          .where((object) =>
              (object.name.toLowerCase().contains(searchValue.toLowerCase()) ||
                  object.description
                      .toLowerCase()
                      .contains(searchValue.toLowerCase())))
          .toList();
    }

    if (ff.isFilterActive) {
      if (filterValue.toLowerCase() != 'all') {
        temp = temp
            .where((object) =>
                object.type.toLowerCase() == filterValue.toLowerCase())
            .toList();
      }
      if (onlyVisible == true) {
        temp = temp.where((object) => object.visible == true).toList();
      }
    } else {
      temp = temp.where((object) => object.visible == true).toList();
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
    if (value != null) filterValue = value;
    if (visible != null) onlyVisible = visible;
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
    Map<String, dynamic> newDate =
        await SelectDate.selectDate(context, _selectedDate, _selectedTime);
    if (newDate['nopickup'] == false) {
      _selectedDate = newDate['date'];
      _selectedTime = newDate['time'];
      _getNewCatalog();
    }
  }

  Future<void> _currentDate(BuildContext context) async {
    await SelectDate.currentDate();
    _getNewCatalog();
  }

  void update(int index, bool value) {
    String objectName = _catalog[index].name;
    ObjectSelection()
        .selection
        .firstWhere((k) => k.name == objectName)
        .selected = value;
    setState(() {
      _catalog[index].selected = value;
      mappingRatingBox[_catalog[index].name]?.currentState?.build(context);
    });
  }

  void refreshPage() async {
    if (!mounted) return;
    if (await SelectDate.isRealTime()) {
      await SelectDate.currentDate();
      _getNewCatalog();
    }
  }

  @override
  void initState() {
    super.initState();
    if (!CurrentLocation().isSetup) {
      Navigator.pushReplacementNamed(context, '/check');
    }
    sf.setCallBack(search);
    ff.setCallBack(filter);
    _getNewCatalog();

    mappingRatingBox.clear();
    bbar.addItem(const Icon(Icons.schedule), 'change_date'.tr(), _selectDate);
    bbar.addItem(const Icon(Icons.restore), 'hour_title'.tr(), _currentDate);
    bbar.addItem(const Icon(Icons.filter_alt), 'filter'.tr(), _filter);
    bbar.addItem(const Icon(Icons.search), 'search'.tr(), _search);

    timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      refreshPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageStructure(
        body: Container(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(children: [
              Text(ObjectSelection().astro!.getDateTimeString()),
              sf.buildSearchTextField(),
              ff.buildFilterTextField(ObjectSelection().selection.toList()),
              Expanded(
                  child: ListView.builder(
                      itemCount: _catalog.length,
                      itemBuilder: (context, index) {
                        GlobalKey<RatingBoxState> childKey =
                            GlobalKey<RatingBoxState>();
                        RatingBox rating = RatingBox(
                            key: childKey,
                            onValueChanged: update,
                            index: index,
                            initialValue: _catalog[index].selected);
                        mappingRatingBox[_catalog[index].name] = childKey;

                        return GestureDetector(
                            child: ObjectBox(
                                object: _catalog[index], rating: rating),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ObjectPage(
                                      item: _catalog[index],
                                      index: index,
                                      onValueChanged: update,
                                      initialValue: _catalog[index].selected),
                                ),
                              );
                            },
                            onLongPress: () {
                              Navigator.pushReplacementNamed(
                                  context, '/capture',
                                  arguments: {'object': _catalog[index].name});
                            });
                      })),
            ])),
        bottom: bbar);
  }
}
