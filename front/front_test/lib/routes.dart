
import 'package:flutter/widgets.dart';
import 'package:front_test/screens/screencapture.dart';
import 'package:front_test/screens/screencheck.dart';
import 'package:front_test/screens/screenobjectlist.dart';
import 'package:front_test/screens/screenconnection.dart';
import 'package:front_test/screens/screenselectiontlist.dart';
import 'package:front_test/screens/screenconfig.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
     
      "/" : (BuildContext context) => CheckScreen(), 
      "/check" : (BuildContext context) => CheckScreen(),
      "/home": (BuildContext context) => ScreenObjectList(),
      "/selection": (BuildContext context) => ScreenSelectionList(),
      "/capture": (BuildContext context) => ScreenCapture(),
      "/connect": (BuildContext context) => ConnectionPage(),
      "/config": (BuildContext context) => ConfigScreen(),
};