


import 'package:flutter/material.dart';
import 'dart:math';

class CircularButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final String label;

  const CircularButton({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.label,
  });


  @override
  Widget build(BuildContext context) {
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Colors.green : Colors.red,
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ),
      ),
    );
  }
}


class CircularButtonSelection extends StatefulWidget {

  final String name;
  final  Function(String, dynamic) callBack;
  final List<bool> selectedButtons;

  const CircularButtonSelection(
      {super.key, required this.selectedButtons, required this.name, required this.callBack});


  @override
  State<CircularButtonSelection> createState() => _CircularButtonSelectionState();
}

class _CircularButtonSelectionState extends State<CircularButtonSelection> {
  late List<bool> selectedButtons;


  @override
  void initState() {
    super.initState();
    selectedButtons= widget.selectedButtons;
  }
  void toggleButton(int index) {
    setState(() {
      selectedButtons[index] = !selectedButtons[index];
    });
  }

  List<bool> getValues() {
    return selectedButtons;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: SizedBox(
          width: 350,
          height: 350,
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(36, (index) {
              double angle = index * 10.0 - 90; // Adjusting angle for compass orientation
              double radius = 150.0;
              double radian = angle * pi / 180;
              String label="";
              switch(index) {
                case 0: label="N";break;
                case 9: label = "E"; break;
                case 18: label = "S";break;
                case 27: label = "W";break;
                default: label=(index * 10).toString();
              }
              return Transform.translate(
                offset: Offset(
                  radius * cos(radian),
                  radius * sin(radian),
                ),
                child: CircularButton(
                  isSelected: selectedButtons[index],
                  onTap: ()  {
                      toggleButton(index);
                      widget.callBack(widget.name, selectedButtons);
                  },
                  label: label,
                ),
              );
            }),
          ),
        ),
      )
    );
  }
}