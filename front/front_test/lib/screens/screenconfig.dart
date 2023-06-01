import 'package:flutter/material.dart';
import 'package:front_test/services/servicecheck.dart';
import 'package:front_test/services/globals.dart';
import 'package:front_test/components/pagestructure.dart';
import 'package:front_test/components/progression.dart';

class ConfigScreen extends StatelessWidget {
  final ServiceCheckHelper checkHelper = ServiceCheckHelper();

  Future<dynamic> update() async {
    return await checkHelper.getDarkProgession();

  }

  @override
  Widget build(BuildContext context) {
    return PageStructure(
            body: 
              Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:<Widget>[
                           const Text('Take darks'),
                           ElevatedButton(
                              onPressed: () async { 
                                checkHelper.takeDark();
                                showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              content: LoadingIndicator(
                                                text: 'Taking dark', controller: update
                                              ),
                                            );
                                          },
                                        );
                              },
                              child: const Text('Go')
                           )
                            
          ]));
  }
}