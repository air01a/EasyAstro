import 'package:easyastro/services/localstoragehelper.dart';


class ConfigManager {
  static final ConfigManager _singleton = ConfigManager._internal();
  final _ls = LocalStorage('Configuration');
  Map<String, dynamic>? configuration;
  
  factory ConfigManager() {
    return _singleton;
  }

  void loadConfig() async {
    configuration = await _ls.getAllSelections();
  }


  void saveConfig() async {

  }

  ConfigManager._internal();


}