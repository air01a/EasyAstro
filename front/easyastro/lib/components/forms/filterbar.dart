import 'package:flutter/material.dart';
import 'package:easyastro/models/catalogs.dart';
import 'package:easy_localization/easy_localization.dart';

class FilterField {
  late Function(String?, bool?) callback;
  bool isFilterActive = false;
  bool onlyVisible = true;
  FocusNode myFocusNode = FocusNode();
  FilterField();
  String currentSelected = 'all';

  void filterActivate() {
    isFilterActive = !isFilterActive;
    if (isFilterActive) {
      myFocusNode.requestFocus();
    }
  }

  void setCallBack(Function(String?, bool?) cb) {
    callback = cb;
  }

  List<String> getType(List<ObservableObject> results) {
    Set<String> ret = {};
    // List<ObservableObject> results = ObjectSelection().selection.toList();
    ret.add('all');
    for (ObservableObject object in results) {
      ret.add(object.type);
    }
    return ret.toList();
  }

  Widget buildFilterTextField(List<ObservableObject> objects) {
    if (isFilterActive) {
      final values = getType(objects);
      return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          direction: Axis.horizontal,
          spacing: 5,
          children: [
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                child: DropdownButton<String>(
                    value:
                        currentSelected, // La valeur sélectionnée dans la liste déroulante
                    items: values.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value).tr(),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        currentSelected = newValue;
                        callback(newValue, null);
                      }
                    })),
            Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
              const Text('only_visible').tr(),
              Checkbox(
                  checkColor: Colors.white,
                  value: onlyVisible,
                  onChanged: (bool? value) {
                    onlyVisible = !onlyVisible;

                    callback(null, onlyVisible);
                  })
            ])
          ]);
    } else {
      return const SizedBox(width: 0, height: 0);
    }
  }
/*
  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }*/
}
