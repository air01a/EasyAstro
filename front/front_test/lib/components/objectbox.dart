import 'package:flutter/material.dart';
import 'package:front_test/components/rating.dart';
import 'package:front_test/models/catalogs.dart'; 
import 'package:front_test/services/globals.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
      Image currentImage;
      if (kIsWeb) {
          currentImage = Image.network(widget.object.image, width: 100);
      } else {
          currentImage = Image(image:AssetImage(widget.object.image),width:100);
      }
      
      //final rbox = RatingBox(onValueChanged: onValueChanged, index: widget.item, initialValue: ObjectSelection().selection[widget.item].selected);
      return Container(
         padding: const EdgeInsets.all(2), 
         height: 140, 
         child: Card(
            child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
               children: <Widget>[ 
                  currentImage, 
                  Expanded( 
                     child: Container( 
                        padding: const EdgeInsets.all(5), 
                        child: Column( 
                           mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                           children: <Widget>[ 
                              Text(widget.object.name, style: const TextStyle(fontWeight: FontWeight.bold)), Text(widget.object.description), 
                              Text("Type: ${widget.object.type}"), 
                              Text("Magnitude: ${widget.object.magnitude.toString()}"), 
                           ], 
                        )
                     )
                  ),
                  widget.rating,
                  ServerInfo().connected
                   ? ElevatedButton(
                                    onPressed: () { 
                                      Navigator.pushNamed(context, '/capture', arguments: {'object':widget.object.name});
                                    }, 
                                    child: const Icon(
                                                      Icons.mode_standby  ,
                                                      size: 48.0
                                                    )
                                  )
                   : Container(width: 0, height: 0)
                               
               ]
            ), 
         )
      ); 
   } 
}