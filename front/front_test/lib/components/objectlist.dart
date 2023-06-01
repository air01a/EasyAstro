import 'package:flutter/material.dart'; 
import 'package:front_test/components/rating.dart'; 
import 'package:front_test/services/globals.dart';
import 'package:front_test/models/catalogs.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
      if (kIsWeb) {
          currentImage = Image.network(widget.item.image);
      } else {
          currentImage = Image(image:AssetImage(widget.item.image));
      }
      

      return Scaffold(
         appBar: AppBar(
            title: Text(widget.item.name), 
         ), 
         body: Center(
            child: SingleChildScrollView(
              child: IntrinsicHeight(
            
                child: Container( 
                  padding: const EdgeInsets.all(0), 
                  child: Column( 
                      mainAxisAlignment: MainAxisAlignment.start, 
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: <Widget>[ 
                        Center(child : currentImage),  
                        Expanded( 
                            child: Container( 
                              padding: const EdgeInsets.all(5), 
                              child: Column( 
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                                  children: <Widget>[ 
                                    Text(widget.item.name, style: const TextStyle(fontWeight: FontWeight.bold)), 
                                    Text(widget.item.description,textAlign: TextAlign.left), 
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
        ) 
      )); 
   } 
}
