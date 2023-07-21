import 'package:flutter/material.dart';
import 'package:easyastro/models/configmodel.dart';
import 'package:easy_localization/easy_localization.dart';

class ConfigForms {
  List<Widget> getForms(
      Map<String, ConfigItem>? cnf, Function(String, dynamic) callBack) {
    List<Widget> configReturn = [];

    if (cnf == null) return configReturn;
    cnf.forEach((key, value) {
      ConfigItem ci = value;

      if (ci.type == 'checkbox') {
        configReturn.add(Row(children: [
          Expanded(
              flex: 5,
              child: Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  alignment: Alignment.centerLeft,
                  child: Text(ci.description).tr())),
          Expanded(
              flex: 5,
              child: Container(
                  alignment: Alignment.centerLeft,
                  child: Checkbox(
                      value: ci.value,
                      onChanged: (value) => callBack(key, value))))
        ]));
      }

      if (ci.type == 'input') {
        configReturn.add(Row(children: [
          Expanded(
              flex: 5,
              child: Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  alignment: Alignment.centerLeft,
                  child: Text(ci.description).tr())),
          Expanded(
              flex: 5,
              child: Container(
                  alignment: Alignment.centerLeft,
                  child: TextFormField(
                    initialValue: ci.value,
                    onChanged: (value) => callBack(key, value),
                  )))
        ]));
      }

      if (ci.type == 'select') {
        configReturn.add(Row(children: [
          Expanded(
              flex: 5,
              child: Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  alignment: Alignment.centerLeft,
                  child: Text(ci.description).tr())),
          Expanded(
              flex: 5,
              child: Container(
                  alignment: Alignment.centerLeft,
                  child: DropdownButton<String>(
                    value: ci.value,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    onChanged: (value) => callBack(key, value),
                    items: ci.attributes
                        .map<DropdownMenuItem<String>>((dynamic value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  )))
        ]));
      }

      configReturn.add(const Divider(height: 3));
    });

    configReturn.add(Container(height: 10));

    return configReturn;
  }
}
