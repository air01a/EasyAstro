import 'package:flutter/material.dart';
import 'package:front_test/components/rating.dart';
import 'package:front_test/models/catalogs.dart'; 
import 'package:front_test/services/globals.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:front_test/astro/astrocalc.dart';

class ObjectBox extends StatefulWidget {
    // final Function() onValueChanged;
   final RatingBox rating; 
  final ObservableObject object;
  const ObjectBox({super.key,required this.object, required this.rating}); 

  @override 
  State<ObjectBox> createState() => _ObjectBox(); 

}



class _ObjectBox extends State<ObjectBox> {
   Color getColor(bool isVisible, double height) {
    if (!isVisible) return Colors.red.shade800;
    if (height<20) return Colors.grey.shade800;
    return Theme.of(context).primaryColor;


   }
   @override
   Widget build(BuildContext context) {
      Image currentImage;
      double imageSize;
      if (kIsWeb) {
          currentImage = Image.network(widget.object.image);
          imageSize=200;
      } else {
          currentImage = Image(image:AssetImage(widget.object.image));
          imageSize=150;
      }
      Container containerImage=Container(
      height: 200,  
      decoration: new BoxDecoration(
          color:  getColor(widget.object.visible, widget.object.height),
          shape: BoxShape.circle,
          image: new DecorationImage(
          fit: BoxFit.cover,
          image: currentImage.image,
          
        )
      ,));
      //final rbox = RatingBox(onValueChanged: onValueChanged, index: widget.item, initialValue: ObjectSelection().selection[widget.item].selected);
      return Container(
        
         padding: const EdgeInsets.all(2), 
         height: 140, 
         child: Card(
            color:  getColor(widget.object.visible, widget.object.height),//Theme.of(context).primaryColor,
            child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
               children: <Widget>[ 
                  Container(
                    width: imageSize,
                    height: imageSize,
                    
                    decoration: new BoxDecoration(
                                        color:  getColor(widget.object.visible, widget.object.height),//Theme.of(context).primaryColor,
                                        shape: BoxShape.circle,
                                        image: new DecorationImage(
                                            fit: BoxFit.contain,
                                            image: currentImage.image,
                                        )
                    )), 
                  Expanded( 
                     child: Container( 
                        color: getColor(widget.object.visible, widget.object.height),//Theme.of(context).primaryColor,//.withOpacity(0.5),
                        padding: const EdgeInsets.all(5), 
                        child: Column( 
                           mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                           children: <Widget>[ 
                              Text(widget.object.name, style: const TextStyle(fontWeight: FontWeight.bold)), 
                              Text("Rise : ${ConvertAngle.hourToString(widget.object.rise)} - Set : ${ConvertAngle.hourToString(widget.object.set)} "), 
                              Text("Culmination : ${ConvertAngle.hourToString(widget.object.meridian)}"), 
                              Text("Type: ${widget.object.type}"), 
                              Text("Magnitude: ${widget.object.magnitude.toString()}"), 
                           ], 
                        )
                     )
                  ),
                  Container(
                    color:  getColor(widget.object.visible, widget.object.height),//Theme.of(context).primaryColor, //.withOpacity(0.5),
                    child:widget.rating),
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