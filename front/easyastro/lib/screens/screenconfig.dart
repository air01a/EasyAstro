import 'package:flutter/material.dart';
import 'package:easyastro/services/telescope/telescopehelper.dart';
import 'package:easyastro/components/structure/pagestructure.dart';
import 'package:easyastro/services/database/globals.dart';
import 'package:easyastro/services/database/configmanager.dart';
import 'package:easyastro/models/configmodel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easyastro/components/forms/optionsforms.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreen();
}

class _ConfigScreen extends State<ConfigScreen> {
  final TelescopeHelper checkHelper = TelescopeHelper(ServerInfo().host);
  bool _isSaveDisabled = true;
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  Future<dynamic> update() async {
    return await checkHelper.getDarkProgession();
  }

  void changeConfigValue(String key, dynamic value) {
    ConfigManager().update(key, value);

    setState(() {
      _isSaveDisabled = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
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
            onPressed: _isSaveDisabled
                ? null
                : () {
                    ConfigManager().saveConfig();
                    setState(() {
                      _isSaveDisabled = true;
                    });
                  },
            child: const Text("save").tr())));
    configReturn.add(const SizedBox(height: 20));
    configReturn
        .add(Center(child: Text('Version : ${_packageInfo.version} (2024)')));

    
    
    return configReturn;
  }

  @override
  Widget build(BuildContext context) {
    return PageStructure(
        body: SingleChildScrollView(
          child: IntrinsicHeight(
            child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: getConfigItems()))));
  }
}
