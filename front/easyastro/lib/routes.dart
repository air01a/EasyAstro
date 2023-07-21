
import 'package:flutter/widgets.dart';
import 'package:easyastro/screens/screencapture.dart';
import 'package:easyastro/screens/screencheck.dart';
import 'package:easyastro/screens/screenobjectlist.dart';
import 'package:easyastro/screens/screenconnection.dart';
import 'package:easyastro/screens/screenselectiontlist.dart';
import 'package:easyastro/screens/screenconfig.dart';
import 'package:easyastro/screens/screenhome.dart';


//import 'package:easyastro/screens/test.dart';
//import 'package:easyastro/screens/screenprocessimage.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
    //"/" : (BuildContext context) => Test(),
     "/" : (BuildContext context) => CheckScreen(), 
      "/check" : (BuildContext context) => CheckScreen(),
      "/home" : (BuildContext context) => ScreenHome(),
      "/plan": (BuildContext context) => ScreenObjectList(),
      "/selection": (BuildContext context) => ScreenSelectionList(),
      "/capture": (BuildContext context) => ScreenCapture(),
      "/connect": (BuildContext context) => ConnectionPage(),
      "/config": (BuildContext context) => ConfigScreen(),

};