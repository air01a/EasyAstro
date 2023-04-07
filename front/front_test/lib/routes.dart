
import 'package:flutter/widgets.dart';
import 'package:front_test/screens/productdisplay.dart';
import 'package:front_test/screens/test.dart';
import 'package:front_test/screens/connection.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
     
      "/" : (BuildContext context) => const ConnectionPage(), 
      "/home": (BuildContext context) => ProductDisplay(),
      "/selection": (BuildContext context) => ScreenObjectList(),
};