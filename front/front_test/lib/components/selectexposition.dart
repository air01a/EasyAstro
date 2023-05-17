import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class ExpositionSelector {

final  pickerData = '''
                      [
        "AUTO",                
        "0.001",
        "0.01",
        "0.1",
        "0.2",
        "0.5",
        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "7",
        "8",
        "9",
        "10",
        "15",
        "20"
    ]''';



 showExpositionSelector(BuildContext context, Future<void> Function(String) callback) async  {
      final result = await Picker(
        adapter: PickerDataAdapter<String>(pickerData:  const JsonDecoder().convert(pickerData)),
        changeToFirst: true,
        hideHeader: false,
        onConfirm: (Picker picker, List value) {
          print(value.toString());
          print(picker.adapter.text);
          callback(picker.getSelectedValues()[0]);
        }
      ).showModal(context); //_scaffoldKey.currentState);
    }
}