import 'package:flutter/material.dart';

class theme {


  static ThemeData dark() {
      return ThemeData(
        // Define the default brightness and colors.
        brightness: Brightness.dark,
        primaryColor: Color.fromARGB(140, 1, 7, 10),
        // Define the default font family.
        fontFamily: 'Georgia',

        scaffoldBackgroundColor: Color.fromARGB(140, 15, 15, 15),
       /* // Define the default `TextTheme`. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),*/
      );
  }
}