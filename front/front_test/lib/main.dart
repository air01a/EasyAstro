
import 'package:flutter/material.dart';
import 'package:front_test/routes.dart';
import 'package:front_test/services/globals.dart';
import 'package:front_test/theme/theme.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  ServerInfo(); 
  ObjectSelection();

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
