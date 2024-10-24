import 'package:flutter/widgets.dart';
import 'package:easyastro/screens/screencapture.dart';
import 'package:easyastro/screens/screencheck.dart';
import 'package:easyastro/screens/screenobjectlist.dart';
import 'package:easyastro/screens/screenconnection.dart';
import 'package:easyastro/screens/screenselectiontlist.dart';
import 'package:easyastro/screens/screenconfig.dart';
import 'package:easyastro/screens/screenhome.dart';
import 'package:easyastro/screens/screenmap.dart';
import 'package:easyastro/screens/screensidereal.dart';
import 'package:easyastro/screens/screencompass.dart';

//import 'package:easyastro/screens/test.dart';
//import 'package:easyastro/screens/screenprocessimage.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  //"/" : (BuildContext context) => Test(),
  "/": (BuildContext context) => const CheckScreen(),
  "/check": (BuildContext context) => const CheckScreen(),
  "/home": (BuildContext context) => const ScreenHome(),
  "/plan": (BuildContext context) => const ScreenObjectList(),
  "/map": (BuildContext context) => const ScreenMap(),
  "/selection": (BuildContext context) => const ScreenSelectionList(),
  "/sidereal": (BuildContext context) => const ScreenClock(),
  "/compass":(BuildContext context) => const ScreenCompass(),
  "/capture": (BuildContext context) => const ScreenCapture(),
  "/connect": (BuildContext context) => const ConnectionPage(),
  "/config": (BuildContext context) => const ConfigScreen(),
};
