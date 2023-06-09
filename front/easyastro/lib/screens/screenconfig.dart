import 'package:flutter/material.dart';
import 'package:easyastro/services/telescopeHelper.dart';
import 'package:easyastro/components/pagestructure.dart';
import 'package:easyastro/components/progression.dart';
import 'package:easyastro/services/globals.dart';
import 'package:easyastro/services/ConfigManager.dart';
import 'package:easyastro/models/configmodel.dart';


class ConfigScreen extends StatefulWidget {
  @override
  _ConfigScreen createState() => _ConfigScreen();
}

class _ConfigScreen extends State<ConfigScreen> {
  final TelescopeHelper checkHelper = TelescopeHelper(ServerInfo().host);

  Future<dynamic> update() async {
    return await checkHelper.getDarkProgession();

  }

  void changeConfigValue(String key,dynamic value) {
    ConfigManager().configuration![key]!.value = value; 
    
    setState(() {});
  }


  List<Widget> getConfigItems() {
    List<Widget> configReturn = [];
    Map<String, ConfigItem>? cnf = ConfigManager().configuration;
    if (cnf==null) return configReturn;
    cnf.forEach((key, value) {
      ConfigItem ci = value;

      print("${ci.name}:${ci.type}:${ci.value}");

      if (ci.type=='checkbox') {
        configReturn.add(Row(
          children:[
          Expanded(flex: 5, child:Container(margin: EdgeInsets.fromLTRB(10,0,0,0),alignment: Alignment.centerLeft,child: Text(ci.description))),
          Expanded(flex:5, child: Container(alignment: Alignment.centerLeft,child: Checkbox(value: ci.value,
                  onChanged: (value) => changeConfigValue(key, value))))
          
        ]));
      }
      
      if (ci.type=='input') {
          configReturn.add(Row(
          children:[ Expanded(flex: 5, child:Container(margin: EdgeInsets.fromLTRB(10,0,0,0),alignment: Alignment.centerLeft,child:Text(ci.description))),
                     Expanded(flex:5,child:Container(alignment: Alignment.centerLeft,child:TextFormField(
                            onChanged: (value) => changeConfigValue(key, value)
                    ,)))]));
      }
        configReturn.add(const Divider(height: 3));
      
    });
    configReturn.add(Container(height:10));
    configReturn.add(Center(child: ElevatedButton(child:Text("Save"), onPressed: () => { ConfigManager().saveConfig() })));
    return configReturn;

  }

  @override
  Widget build(BuildContext context) {
    return PageStructure(
            body: 
              Column(
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