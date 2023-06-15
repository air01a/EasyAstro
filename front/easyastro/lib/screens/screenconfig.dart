import 'package:flutter/material.dart';
import 'package:easyastro/services/telescopeHelper.dart';
import 'package:easyastro/components/pagestructure.dart';
import 'package:easyastro/services/globals.dart';
import 'package:easyastro/services/configmanager.dart';
import 'package:easyastro/models/configmodel.dart';
import 'package:easy_localization/easy_localization.dart';

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

  void changeConfigValue(String key,dynamic value) {
    ConfigManager().update(key, value); 
    
    setState(() { _isSaveDisabled = false ;});
  }


  List<Widget> getConfigItems() {
    List<Widget> configReturn = [];
    Map<String, ConfigItem>? cnf = ConfigManager().configuration;
    if (cnf==null) return configReturn;
    cnf.forEach((key, value) {
      ConfigItem ci = value;


      if (ci.type=='checkbox') {
        configReturn.add(Row(
          children:[
          Expanded(flex: 5, child:Container(margin: EdgeInsets.fromLTRB(10,0,0,0),alignment: Alignment.centerLeft,child: Text(ci.description).tr())),
          Expanded(flex:5, child: Container(alignment: Alignment.centerLeft,child: Checkbox(value: ci.value,
                  onChanged: (value) => changeConfigValue(key, value))))
          
        ]));
      }
      
      if (ci.type=='input') {
          configReturn.add(Row(
          children:[ Expanded(flex: 5, child:Container(margin: EdgeInsets.fromLTRB(10,0,0,0),alignment: Alignment.centerLeft,child:Text(ci.description).tr())),
                     Expanded(flex:5,child:Container(alignment: Alignment.centerLeft,child:TextFormField(initialValue: ci.value,
                            onChanged: (value) => changeConfigValue(key, value)
                    ,)))]));
      }

       if (ci.type=='select') {

          configReturn.add(Row(
          children:[ Expanded(flex: 5, child:Container(margin: EdgeInsets.fromLTRB(10,0,0,0),alignment: Alignment.centerLeft,child:Text(ci.description).tr())),
                     Expanded(flex:5,child:Container(alignment: Alignment.centerLeft,
                     child: DropdownButton<String>(
                            value: ci.value,
                            icon: const Icon(Icons.arrow_downward),
                            elevation: 16,
                            onChanged:  (value) => changeConfigValue(key, value),
                            items: ci.attributes.map<DropdownMenuItem<String>>((dynamic value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        )
            ))]));
      }


      configReturn.add(const Divider(height: 3));
      
    });

    configReturn.add(Container(height:10));
    configReturn.add(Center(child: ElevatedButton(child:const Text("save").tr(), onPressed: _isSaveDisabled? null : () { ConfigManager().saveConfig();setState(() {
      _isSaveDisabled=true;
    });})));
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