import 'package:flutter/material.dart'; 


class RatingBox extends StatefulWidget { 
  final Function(bool) onValueChanged;
  final bool initialValue; 

  const RatingBox({super.key, required this.onValueChanged, required this.initialValue});
   @override 
   State<RatingBox> createState() => _RatingBoxState(selected: initialValue); 
} 

class _RatingBoxState extends State<RatingBox> { 
   bool selected;
  _RatingBoxState({required this.selected});

   void _setSelected() {
      setState(() {
         selected = selected == false; 
          widget.onValueChanged(selected);
      }); 
   }

   @override
   Widget build(BuildContext context) {
      double size = 30; 

      return Row(
         mainAxisAlignment: MainAxisAlignment.end, 
         crossAxisAlignment: CrossAxisAlignment.end, 
         mainAxisSize: MainAxisSize.max, 
         children: <Widget>[
            Container(
               padding: const EdgeInsets.all(0), 
               child: IconButton(
                  icon: (
                     selected == true ? Icon( 
                        Icons.star, 
                        size: size, 
                     ) 
                     : Icon( 
                        Icons.star_border, 
                        size: size, 
                     )
                  ), 
                  color: Colors.red[500], 
                  onPressed: _setSelected, 
                  iconSize: size, 
               ), 
            ),
         ], 
      ); 
   } 
} 