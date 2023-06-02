import 'package:flutter/material.dart'; 
import 'package:front_test/components/rating.dart'; 
import 'package:front_test/services/globals.dart';
import 'package:front_test/models/catalogs.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:front_test/components/pagestructure.dart';
import 'package:front_test/astro/astrocalc.dart';

class ObjectPage extends StatefulWidget { 
  final ObservableObject item; 
  final RatingBox rating; 

  const ObjectPage({super.key, required this.item, required this.rating});
  @override 
  State<ObjectPage> createState() => _ObjectPage(); 
} 



class _ObjectPage extends State<ObjectPage> {
   @override 
   Widget build(BuildContext context) {
      Image currentImage;
      double imageSize;
      if (kIsWeb) {
          currentImage = Image.network(widget.item.image);
          imageSize=400;
      } else {
          currentImage = Image(image:AssetImage(widget.item.image));
          imageSize=150;
      }
      

      return PageStructure(body: Center(
            child: SingleChildScrollView(
              child: IntrinsicHeight(
            
                child: Container( 
                  color: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.all(5), 
                  child: Column( 
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: <Widget>[ 
                        Center(child : 
                          Container(
                              width: 400.0,
                              height: 400.0,
                              decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            fit: BoxFit.contain,
                                            image: currentImage.image,
                                        )
                                ))
                        
                        ),  
                        Expanded( 
                            child: Container( 
                              padding: const EdgeInsets.all(5), 
                              child: Column( 
                                  mainAxisAlignment: MainAxisAlignment.start, 
                                  children: <Widget>[ 
                                    Container(margin: EdgeInsets.symmetric(vertical: 10.0), child:Text(widget.item.name, style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 15))), 
                                    Container(margin: EdgeInsets.symmetric(vertical: 10.0), child:Text(widget.item.description,textAlign: TextAlign.left,maxLines: 4,)), 
                                    Text("Rise : ${ConvertAngle.hourToString(widget.item.rise)}"),
                                    Text("Set : ${ConvertAngle.hourToString(widget.item.set)}"), 
                                    Text("Culmination : ${ConvertAngle.hourToString(widget.item.meridian)}"), 
                                    Text("Magnitude : ${widget.item.magnitude.toString()}", textAlign: TextAlign.left), 
                                    widget.rating,
                                    ServerInfo().connected
                                        ?ElevatedButton(
                                        onPressed: () { 
                                          Navigator.pushNamed(context, '/capture', arguments: {'object':widget.item.name});
                                        }, 
                                        child: const Icon(
                                                          Icons.mode_standby  ,
                                                          size: 48.0
                                                        )
                                      )
                                      : Container(width: 0, height: 0)
                                  ], 
                              )
                            )
                        ) 
                      ]
                  ), 
                ), 
         ),
        )), showDrawer: false, title:widget.item.name) ;

   } 
}
