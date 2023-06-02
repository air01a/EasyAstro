import 'package:flutter/material.dart';
import 'package:front_test/components/appdrawer.dart';


class PageStructure extends StatelessWidget {
   final Widget body;
   final Widget? bottom;
   bool? showDrawer=true;
   String? title='';

   PageStructure({super.key, required this.body, this.bottom, this.showDrawer=true, this.title});

  @override
  Widget build(BuildContext context) {
              if (showDrawer==true) {
                  return 
                      Scaffold(
                              appBar: AppBar(title: const Text("Easy Astro")),
                              drawer:AppDrawer() ,
                              body : Container( 
                                  decoration: BoxDecoration( 
                                    image: DecorationImage( 
                                      image: AssetImage
                                        ("assets/appimages/background_dark.jpg"
                                      ), 
                                  fit: BoxFit.cover, ), 
                                  ),
                                  child: body),
                              bottomNavigationBar : bottom
                          );
              } else {
                return 
                      Scaffold(
                              appBar: AppBar(
                                    title: Text(title!), 
                                ), 
                              body : Container( 
                                  decoration: BoxDecoration( 
                                    image: DecorationImage( 
                                      image: AssetImage
                                        ("assets/appimages/background_dark.jpg"
                                      ), 
                                  fit: BoxFit.cover, ), 
                                  ),
                                  child: body)
                          );
              }
  }
}