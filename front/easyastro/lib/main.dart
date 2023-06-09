
import 'package:flutter/material.dart';
import 'package:easyastro/routes.dart';
import 'package:easyastro/services/globals.dart';
import 'package:easyastro/theme/theme.dart';
import 'package:easyastro/services/ConfigManager.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  ServerInfo(); 
  ObjectSelection();
  ConfigManager();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
          theme:theme.dark(), 
          routes:routes,
        );
      
  }
}
