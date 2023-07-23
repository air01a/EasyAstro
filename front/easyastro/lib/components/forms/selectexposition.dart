import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class ExpositionSelector {
  final pickerData = '''
                      [[
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
    ],[100,200,300,400,500,600,700,800]]''';

  showExpositionSelector(
      BuildContext context, Future<void> Function(double, int) callback) async {
    Picker picker = Picker(
        adapter: PickerDataAdapter<String>(
            pickerData: const JsonDecoder().convert(pickerData), isArray: true),
        changeToFirst: true,
        hideHeader: false,
        textAlign: TextAlign.left,
        title: const Text("Expo / Gain"),
        selectedTextStyle: TextStyle(color: Colors.red),
        columnPadding: const EdgeInsets.all(8.0),
        onConfirm: (Picker picker, List value) {
          print(picker.getSelectedValues());
          double exposition = 0;
          if (picker.getSelectedValues()[0] == 'AUTO') {
            exposition = -1;
          } else {
            exposition = double.parse(picker.getSelectedValues()[0]);
          }
          callback(exposition, int.parse(picker.getSelectedValues()[1]));
        }); //.showModal(context); //_scaffoldKey.currentState);
    picker.showBottomSheet(context);
  }
}
