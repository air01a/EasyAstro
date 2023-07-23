import 'package:flutter/material.dart';
import 'package:easyastro/components/structure/pagestructure.dart';
import 'package:easyastro/models/catalogs.dart';
import 'package:easyastro/components/elements/objectlist.dart';
import 'package:easyastro/components/elements/objectbox.dart';
import 'package:easyastro/services/database/globals.dart';
import 'package:easyastro/components/elements/rating.dart';
import 'package:easyastro/services/location/locationHelper.dart';
import 'package:easyastro/components/structure/bottombar.dart';
import 'package:easyastro/services/database/localstoragehelper.dart';
import 'package:easyastro/components/forms/storeselection.dart';
import 'package:easyastro/astro/astrocalc.dart';
import 'package:easyastro/models/selection.dart';

class ScreenSelectionList extends StatefulWidget {
  @override
  _ScreenSelectionList createState() => _ScreenSelectionList();
}

class _ScreenSelectionList extends State<ScreenSelectionList> {
  List<ObservableObject> _catalog = <ObservableObject>[];
  final service = LocationHelper();

  void update(int index, bool value) {
    ObjectSelection()
        .selection[ObservableObjects.getObjectIndex(
            _catalog[index].name, ObjectSelection().selection)]
        .selected = value;
    if (value == false) _catalog.removeAt(index);
    setState(() {
      _catalog.length;
      //_catalog[index].selected = value;

      //_catalog  = ObjectSelect;ion().selection.where((line) => line.selected == true).toList();
      //_catalog.sort((a, b) => a.timeToMeridian.compareTo(b.timeToMeridian));
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _catalog = ObjectSelection()
          .selection
          .where((line) => line.selected == true)
          .toList();
      _catalog.sort((a, b) => a.timeToMeridian.compareTo(b.timeToMeridian));
    });
  }

  void callback(Map<String, dynamic> selection) {
    setState(() {
      String newDate =
          "${selection!['date'].toString()} ${ConvertAngle.hourToString(selection['hour'])}";
      service.updateTime(newDate).then((value) {
        List<dynamic> selected = selection["selected"];
        selected.forEach((element) {
          ObjectSelection()
              .selection
              .firstWhere((obj) => obj.name == element)
              .selected = true;
        });
        _catalog = ObjectSelection()
            .selection
            .where((line) => line.selected == true)
            .toList();
      });
    });
  }

  void _load(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            LoadSelection(title: 'Load planned selection', callback: callback),
      ),
    );
  }

  void _save(BuildContext context) {
    final ls = LocalStorage('selection');
    List<String> selected = _catalog.map((object) => object.name).toList();
    String date = ObjectSelection().astro!.getDate();
    double hour = ObjectSelection().astro!.hour;
    double longitude = ObjectSelection().astro!.longitude;
    double latitude = ObjectSelection().astro!.latitude;
    double altitude = ObjectSelection().astro!.altitude;

    SelectionStructure selection = SelectionStructure(
        altitude: altitude,
        date: date,
        hour: hour,
        longitude: longitude,
        latitude: latitude,
        selected: selected);
    ls.addSelection(selection.toJson());
  }

  @override
  Widget build(BuildContext context) {
    final bbar = BottomBar();

    bbar.addItem(const Icon(Icons.save), 'Save', _save);
    bbar.addItem(const Icon(Icons.download), 'Load', _load);

    return PageStructure(
      body: ListView.builder(
          itemCount: _catalog.length,
          itemBuilder: (context, index) {
            RatingBox rating = RatingBox(
                key: ValueKey(_catalog[index].name),
                onValueChanged: update,
                index: index,
                initialValue: true);
            //rating.noUpdate=true;
            return GestureDetector(
                child: ObjectBox(
                    object: _catalog[index],
                    rating: rating), //, onValueChanged: update),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ObjectPage(item: _catalog[index], rating: rating),
                    ),
                  );
                },
                onLongPress: () {
                  Navigator.pushReplacementNamed(context, '/capture',
                      arguments: {
                        'object': ObjectSelection().selection[index].name
                      });
                });
          }),
      bottom: bbar,
    );
  }
}
