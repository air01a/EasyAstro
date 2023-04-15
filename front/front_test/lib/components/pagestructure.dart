import 'package:flutter/material.dart';
import 'package:front_test/components/appdrawer.dart';
import 'package:front_test/services/globals.dart';
import 'package:front_test/screens/screenconnection.dart';

class PageStructure extends StatelessWidget {
   final Widget body;
   final Widget? bottom;
   const PageStructure({super.key, required this.body, this.bottom});

  @override
  Widget build(BuildContext context) {
              if (ServerInfo().host=="") {
                return const ConnectionPage();
              }

              return Scaffold(
                          appBar: AppBar(title: const Text("Easy Astro")),
                          drawer: const AppDrawer(),
                          body : body,
                          bottomNavigationBar : bottom
                      );
  }
}