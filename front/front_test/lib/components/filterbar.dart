import 'package:flutter/material.dart';
import 'package:front_test/models/catalogs.dart'; 
import 'package:front_test/services/globals.dart';

class FilterField {
  late Function(String) callback;
  bool isFilterActive = false;
  FocusNode myFocusNode = FocusNode();
  FilterField();

  void filterActivate() {
    isFilterActive = ! isFilterActive;
    if (isFilterActive) {
      myFocusNode.requestFocus();
    }
  }

  void setCallBack(Function(String) cb) {
    callback = cb;
  }

  List<String> getType() {
    Set<String> ret = {};
    List<ObservableObject> results = ObjectSelection().selection;

    for (ObservableObject object in results) {
      ret.add(object.type);
    }    
    return ret.toList();
  }

  Widget buildFilterTextField() {
    if (isFilterActive) {
      final values = getType();
      return Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0),
            child: DropdownButton<String>(
            value: values[0], // La valeur sélectionnée dans la liste déroulante
            items: values.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String ?newValue) {
              if (newValue!=null) {
                callback(newValue);
              }
            })
            );
            
    
      } else {
      return Container(width: 0, height: 0);
    }
  }
/*
  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }*/
}