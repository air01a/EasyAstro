import 'package:flutter/material.dart';
import 'package:front_test/components/rating.dart';
import 'package:front_test/models/catalogs.dart'; 
import 'package:front_test/services/globals.dart';

class ObjectBox extends StatefulWidget {
    // final Function() onValueChanged;
   final RatingBox rating; 
  final ObservableObject object;
  const ObjectBox({super.key,required this.object, required this.rating}); 

  @override 
  State<ObjectBox> createState() => _ObjectBox(); 

}


class _ObjectBox extends State<ObjectBox> {


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
                  Image.network("http://${ServerInfo().host}${widget.object.image}", width: 100), 
                  Expanded( 
                     child: Container( 
                        padding: const EdgeInsets.all(5), 
                        child: Column( 
                           mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                           children: <Widget>[ 
                              Text(widget.object.name, style: const TextStyle(fontWeight: FontWeight.bold)), Text(widget.object.description), 
                              Text("Type: ${widget.object.type}"), 
                              Text("Magnitude: ${widget.object.magnitude.toString()}"), 
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