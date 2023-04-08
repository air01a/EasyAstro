import 'package:flutter/material.dart';
import 'package:front_test/models/catalogs.dart'; 
import 'package:front_test/components/rating.dart'; 
import 'package:front_test/services/globals.dart';

class ObjectBox extends StatefulWidget {
  final int item; 
  // final Function() onValueChanged;
   final RatingBox rating; 
  const ObjectBox({super.key,required this.item, required this.rating}); 

    @override 
  State<ObjectBox> createState() => _ObjectBox(); 

}


class _ObjectBox extends State<ObjectBox> {


   
  void _updateValue(bool newValue) {
    ObjectSelection().selection[widget.item].selected = newValue;

   // onValueChanged();
  }

   @override
   Widget build(BuildContext context) {
      //final rbox = RatingBox(onValueChanged: onValueChanged, index: widget.item, initialValue: ObjectSelection().selection[widget.item].selected);
      return Container(
         padding: const EdgeInsets.all(2), 
         height: 140, 
         child: Card(
            child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
               children: <Widget>[ 
                  Image.network('http://'+ServerInfo().host+ObjectSelection().selection[widget.item].image, width: 100), 
                  Expanded( 
                     child: Container( 
                        padding: const EdgeInsets.all(5), 
                        child: Column( 
                           mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                           children: <Widget>[ 
                              Text(ObjectSelection().selection[widget.item].name, style: const TextStyle(fontWeight: FontWeight.bold)), Text(ObjectSelection().selection[widget.item].description), 
                              Text("Type: ${ObjectSelection().selection[widget.item].type}"), 
                              Text("Magnitude: ${ObjectSelection().selection[widget.item].magnitude.toString()}"), 
                              widget.rating , 
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