import 'package:flutter/material.dart'; 
import 'package:front_test/components/rating.dart'; 
import 'package:front_test/models/catalogs.dart'; 
import 'package:front_test/services/globals.dart';

class ObjectPage extends StatelessWidget {
   const ObjectPage({super.key, required this.item, required this.onValueChanged}); 
   final int item; 
   final Function() onValueChanged;
    
  void _updateValue(bool newValue) {
      ObjectSelection().selection[item].selected=newValue;
   }

   @override 
   Widget build(BuildContext context) {
      return Scaffold(
         appBar: AppBar(
            title: Text(ObjectSelection().selection[item].name), 
         ), 
         body: Center(
            child: Container( 
               padding: const EdgeInsets.all(0), 
               child: Column( 
                  mainAxisAlignment: MainAxisAlignment.start, 
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: <Widget>[ 
                     Image.network('http://'+ServerInfo().host+ObjectSelection().selection[item].image, width: 100),  
                     Expanded( 
                        child: Container( 
                           padding: const EdgeInsets.all(5), 
                           child: Column( 
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                              children: <Widget>[ 
                                 Text(ObjectSelection().selection[item].name, style: const TextStyle(fontWeight: FontWeight.bold)), 
                                 Text(ObjectSelection().selection[item].description,textAlign: TextAlign.left), 
                                 Text("Magnitude : ${ObjectSelection().selection[item].magnitude.toString()}", textAlign: TextAlign.left), 
                                 RatingBox(onValueChanged: _updateValue, initialValue: ObjectSelection().selection[item].selected),
                              ], 
                           )
                        )
                     ) 
                  ]
               ), 
            ), 
         ), 
      ); 
   } 
}
