import 'package:flutter/material.dart';
import 'package:easyastro/services/telescopeHelper.dart';
import 'package:easyastro/components/pagestructure.dart';
import 'package:easyastro/components/progression.dart';
import 'package:easyastro/services/globals.dart';

class ConfigScreen extends StatelessWidget {
  final TelescopeHelper checkHelper = TelescopeHelper(ServerInfo().host);

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