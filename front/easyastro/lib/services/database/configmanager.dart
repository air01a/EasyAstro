import 'package:easyastro/models/configmodel.dart';
import 'package:easyastro/repositories/configurationrepositories.dart';

class ConfigManager {
  static final ConfigManager _singleton = ConfigManager._internal();

  Map<String, ConfigItem>? configuration;
  Map<String, Function(String, dynamic)> callbacks={};

  Future<void> loadConfig() async {
    ConfigurationRepository config = ConfigurationRepository();
    configuration = await config.loadConfig();
  }

  factory ConfigManager() {
    return _singleton;
  }

  Iterable<String> getKey() {
    if (configuration == null) {
      return [];
    }
    return configuration!.keys;
  }

  void saveConfig() async {
    ConfigurationRepository config = ConfigurationRepository();
    if (configuration!=null) config.saveConfig(configuration!);
  }

  void addCallBack(String key, Function(String, dynamic) func) async {
    callbacks[key] = func;

  }

  void update(String key, dynamic value) {
    if (configuration != null && configuration!.keys.contains(key)) {
      configuration![key]!.value = value;
      if (callbacks.keys.contains(key) && callbacks[key]!=null) callbacks[key]!(key, value);
    }
  }

  ConfigManager._internal();


}