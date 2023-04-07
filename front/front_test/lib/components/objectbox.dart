import 'package:flutter/material.dart';
import 'package:front_test/models/catalogs.dart'; 
import 'package:front_test/components/rating.dart'; 
import 'package:front_test/services/globals.dart';

class ObjectBox extends StatelessWidget {
  final int item; 
  final Function() onValueChanged;
  const ObjectBox({super.key,required this.item, required this.onValueChanged}); 
  
   
   void _updateValue(bool newValue) {
      ObjectSelection().selection[item].selected = newValue;
      onValueChanged();
   }

   @override
   Widget build(BuildContext context) {
      return Container(
         padding: const EdgeInsets.all(2), 
         height: 140, 
         child: Card(
            child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
               children: <Widget>[ 
                  Image.network('http://'+ServerInfo().host+ObjectSelection().selection[item].image, width: 100), 
                  Expanded( 
                     child: Container( 
                        padding: const EdgeInsets.all(5), 
                        child: Column( 
                           mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                           children: <Widget>[ 
                              Text(ObjectSelection().selection[item].name, style: const TextStyle(fontWeight: FontWeight.bold)), Text(ObjectSelection().selection[item].description), 
                              Text("Type: ${ObjectSelection().selection[item].type}"), 
                              Text("Magnitude: ${ObjectSelection().selection[item].magnitude.toString()}"), 
                              RatingBox(onValueChanged: _updateValue, initialValue: ObjectSelection().selection[item].selected), 
                           ], 
                        )
                     )
                  ) 
               ]
            ), 
         )
      ); 
   } 
}