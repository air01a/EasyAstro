import 'package:flutter/material.dart';
import 'package:front_test/models/catalogs.dart'; 
import 'package:front_test/services/globals.dart';

class FilterField {
  late Function(String?, bool?) callback;
  bool isFilterActive = false;
  bool onlyVisible = true;
  FocusNode myFocusNode = FocusNode();
  FilterField();
  String currentSelected='All';

  void filterActivate() {
    isFilterActive = ! isFilterActive;
    if (isFilterActive) {
      myFocusNode.requestFocus();
    }
  }

  void setCallBack(Function(String?, bool?) cb) {
    callback = cb;
  }

  List<String> getType() {
    Set<String> ret = {};
    List<ObservableObject> results = ObjectSelection().selection;
    ret.add('All');
    for (ObservableObject object in results) {
      ret.add(object.type);
    }    
    return ret.toList();
  }

  Widget buildFilterTextField() {
    if (isFilterActive) {
      final values = getType();
      return Row(children: [Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0),
            child: DropdownButton<String>(
            value: currentSelected, // La valeur sélectionnée dans la liste déroulante
            items: values.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String ?newValue) {
              if (newValue!=null) {
                currentSelected=newValue;
                callback(newValue, null);
              }
            })
            ),
            Text("Only Visible"),
            Checkbox(
                  checkColor: Colors.white,
                  value: onlyVisible,
                  onChanged: (bool? value) {
                    
                              onlyVisible = !onlyVisible;
    
                              callback(null, onlyVisible);
  
                      }
        )]);
            
    
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