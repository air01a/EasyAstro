import 'package:flutter/material.dart';
import 'package:easyastro/services/telescope/telescopehelper.dart';
import 'package:easyastro/components/structure/pagestructure.dart';
import 'package:easyastro/services/database/globals.dart';
import 'package:easyastro/components/loader/progression.dart';
import 'package:easy_localization/easy_localization.dart';

class ConfigTelescopeScreen extends StatefulWidget {
  const ConfigTelescopeScreen({super.key});

  @override
  State<ConfigTelescopeScreen> createState() => _ConfigTelescopeScreen();
}

class _ConfigTelescopeScreen extends State<ConfigTelescopeScreen> {
  final TelescopeHelper checkHelper = TelescopeHelper(ServerInfo().host);
  List<dynamic> darkLibrary = [];
  String currentDark = '';

  Future<dynamic> update() async {
    dynamic progression = await checkHelper.getDarkProgession();
    if (progression == 100) {
      updateLibrary();
    }
    return progression; 
  }

  void updateLibrary() {
    checkHelper.getDarkLibrary().then((value) {
      darkLibrary = value;
      checkHelper.getCurrentLibrary().then((value) {
        setState(() {
          currentDark = value;
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    updateLibrary();
  }

  void changeLib(String value) {
    checkHelper.changeDark(value).then((value2) {
      setState(
        () => currentDark = value,
      );
    });
  }

  void stopTelescope() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("confirms_stop").tr(),
          content: const Text('confirms_stop').tr(),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                ServerInfo().connected = false;
                Navigator.pushReplacementNamed(context, '/home');
                checkHelper.stopTelescope();
              },
              child: const Text('confirm').tr(),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
              child: const Text('cancel').tr(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageStructure(
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                flex: 5,
                child: Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    alignment: Alignment.centerLeft,
                    child: const Text('take_darks').tr())),
            Expanded(
                flex: 5,
                child: Container(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                        onPressed: () async {
                          checkHelper.takeDark();
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: LoadingIndicator(
                                    text: 'taking_dark'.tr(),
                                    controller: update),
                              );
                            },
                          );
                        },
                        child: const Text('Go')))),
          ]),
          Row(children: [
            Expanded(
                flex: 5,
                child: Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    alignment: Alignment.centerLeft,
                    child: const Text('dark_library').tr())),
            Expanded(
                flex: 5,
                child: Container(
                    alignment: Alignment.centerLeft,
                    child: DropdownButton<String>(
                      value: currentDark,
                      icon: const Icon(Icons.arrow_downward),
                      elevation: 16,
                      onChanged: (value) => changeLib(value!),
                      items: darkLibrary
                          .map<DropdownMenuItem<String>>((dynamic value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    )))
          ]),
          Row(children: [
            Expanded(
                flex: 5,
                child: Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    alignment: Alignment.centerLeft,
                    child: const Text('stop_telescope').tr())),
            Expanded(
                flex: 5,
                child: Container(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                        onPressed: () async {
                          stopTelescope();
                        },
                        child: const Text('stop').tr()))),
          ])
        ]),
        showDrawer: false,
        title: "telescope_option".tr());
  }
}
