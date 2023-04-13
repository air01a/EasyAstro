import 'package:flutter/material.dart'; 
import 'package:front_test/components/rating.dart'; 
import 'package:front_test/services/globals.dart';
import 'package:front_test/components/objectbox.dart';  



class ObjectPage extends StatefulWidget { 
  final int item; 
 final RatingBox rating; 

  const ObjectPage({super.key, required this.item, required this.rating});
  @override 
  State<ObjectPage> createState() => _ObjectPage(); 
} 



class _ObjectPage extends State<ObjectPage> {



  void _updateValue(bool newValue) {
      
      setState(() {
        ObjectSelection().selection[widget.item].selected=newValue;
        ;
        //widget.parent.();
      });
  }

   @override 
   Widget build(BuildContext context) {
      return Scaffold(
         appBar: AppBar(
            title: Text(ObjectSelection().selection[widget.item].name), 
         ), 
         body: Center(
            child: Container( 
               padding: const EdgeInsets.all(0), 
               child: Column( 
                  mainAxisAlignment: MainAxisAlignment.start, 
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: <Widget>[ 
                     Image.network('http://'+ServerInfo().host+ObjectSelection().selection[widget.item].image),  
                     Expanded( 
                        child: Container( 
                           padding: const EdgeInsets.all(5), 
                           child: Column( 
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                              children: <Widget>[ 
                                 Text(ObjectSelection().selection[widget.item].name, style: const TextStyle(fontWeight: FontWeight.bold)), 
                                 Text(ObjectSelection().selection[widget.item].description,textAlign: TextAlign.left), 
                                 Text("Magnitude : ${ObjectSelection().selection[widget.item].magnitude.toString()}", textAlign: TextAlign.left), 
                                 widget.rating,
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
