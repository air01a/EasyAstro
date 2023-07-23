import 'package:flutter/material.dart';
import 'package:easyastro/components/structure/appdrawer.dart';


class PageStructure extends StatelessWidget {
   final Widget body;
   final Widget? bottom;
   final bool? showDrawer;
   final String? title;

   const PageStructure({super.key, required this.body, this.bottom, this.showDrawer=true, this.title});

  @override
  Widget build(BuildContext context) {
              if (showDrawer==true) {
                  return 
                      Scaffold(
                              appBar: AppBar(title: const Text("Easy Astro")),
                              drawer:AppDrawer() ,
                              body : 
                              Container( 
                                height: double.infinity,
                                width: double.infinity,
                                  decoration: BoxDecoration( 
                                    color: Colors.black,
                                    image: DecorationImage( 
                                      colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), 
                                      BlendMode.dstATop),
                                      image: AssetImage
                                        ("assets/appimages/background_dark.jpg"
                                      ), 
                                  fit: BoxFit.cover, ), 
                                  ),
                                  child: body),
                               //  Container(color: Theme.of(context).primaryColor ,child:body),
                              bottomNavigationBar : bottom
                          );
              } else {
                return 
                      Scaffold(
                              appBar: AppBar(
                                    title: Text(title!), 
                                ), 
                              body : Container( 
                                height: double.infinity,
                                width: double.infinity,
                                  decoration: BoxDecoration( 
                                    color: Colors.black,
                                    image: DecorationImage( 
                                      colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), 
                                      BlendMode.dstATop),
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