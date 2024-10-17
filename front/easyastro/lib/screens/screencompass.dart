import 'package:easyastro/components/structure/pagestructure.dart';
import 'package:flutter/material.dart';
import 'package:easyastro/components/graphics/compass.dart';


class ScreenCompass extends StatelessWidget {
  const ScreenCompass({super.key});


  @override
  Widget build(BuildContext context) {
    return const PageStructure(
        body: 
         Center(
        child: Compass())
    );
  }

}
