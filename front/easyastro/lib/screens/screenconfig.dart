import 'package:flutter/material.dart';
import 'package:easyastro/services/telescope/telescopeHelper.dart';
import 'package:easyastro/components/pagestructure.dart';
import 'package:easyastro/services/database/globals.dart';
import 'package:easyastro/services/database/configmanager.dart';
import 'package:easyastro/models/configmodel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easyastro/components/optionsforms.dart';

class ConfigScreen extends StatefulWidget {
  @override
  _ConfigScreen createState() => _ConfigScreen();
}

class _ConfigScreen extends State<ConfigScreen> {
  final TelescopeHelper checkHelper = TelescopeHelper(ServerInfo().host);
  bool _isSaveDisabled = true;

  Future<dynamic> update() async {
    return await checkHelper.getDarkProgession();
  }

  void changeConfigValue(String key, dynamic value) {
    ConfigManager().update(key, value);

    setState(() {
      _isSaveDisabled = false;
    });
  }

  List<Widget> getConfigItems() {
    Map<String, ConfigItem>? cnf = ConfigManager().configuration;
    if (cnf == null) return [];
    ConfigForms configForms = ConfigForms();
    List<Widget> configReturn = configForms.getForms(cnf, changeConfigValue);

    configReturn.add(Container(height: 10));
    configReturn.add(Center(
        child: ElevatedButton(
            child: const Text("save").tr(),
            onPressed: _isSaveDisabled
                ? null
                : () {
                    ConfigManager().saveConfig();
                    setState(() {
                      _isSaveDisabled = true;
                    });
                  })));
    return configReturn;
  }

  @override
  Widget build(BuildContext context) {
    return PageStructure(
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:

                //onPressed: () => { ConfigManager().saveConfig() }
                getConfigItems()

            /*
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
                           ),
                          
                           getConfigItems(), */
            ));
  }
}
