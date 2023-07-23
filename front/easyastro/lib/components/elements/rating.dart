import 'package:flutter/material.dart'; 


class RatingBox extends StatefulWidget { 
  final Function(int, bool) onValueChanged;
  final bool initialValue; 
  final int index; 

  RatingBox({super.key, required this.onValueChanged, required this.index, required this.initialValue});
   @override 
   State<RatingBox> createState() => RatingBoxState(); 
} 

class RatingBoxState extends State<RatingBox> { 
  bool _selected = false;

  RatingBoxState();

   void _setSelected() {
      setState(() {
         _selected = _selected == false;
        widget.onValueChanged(widget.index, _selected);

      });


   }

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue;
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
                     _selected == true ? Icon( 
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