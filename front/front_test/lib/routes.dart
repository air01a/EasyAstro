
import 'package:flutter/widgets.dart';
import 'package:front_test/screens/screencapture.dart';
import 'package:front_test/screens/screencheck.dart';
import 'package:front_test/screens/screenobjectlist.dart';
import 'package:front_test/screens/screenconnection.dart';
import 'package:front_test/screens/screenselectiontlist.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
     
      "/" : (BuildContext context) => const ConnectionPage(), 
      "/check" : (BuildContext context) => CheckScreen(),
      "/home": (BuildContext context) => ScreenObjectList(),
      "/selection": (BuildContext context) => ScreenSelectionList(),
      "/capture": (BuildContext context) => ScreenCapture(),
};