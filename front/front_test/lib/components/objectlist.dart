import 'package:flutter/material.dart'; 
import 'package:front_test/components/rating.dart'; 
import 'package:front_test/services/globals.dart';
import 'package:front_test/models/catalogs.dart';

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
                        Center(child : Image.network("http://${ServerInfo().host}${widget.item.image}")),  
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
                                    ElevatedButton(
                                    onPressed: () { 
                                      Navigator.pushNamed(context, '/capture', arguments: {'object':widget.item.name});
                                    }, 
                                    child: const Icon(
                                                      Icons.mode_standby  ,
                                                      size: 48.0
                                                    )
                                  )
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
