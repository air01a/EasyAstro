import 'package:easyastro/models/configmodel.dart';
import 'package:easyastro/repositories/configurationrepositories.dart';

class ConfigManager {
  static final ConfigManager _singleton = ConfigManager._internal();

  Map<String, ConfigItem>? configuration;

  Future<void> loadConfig() async {
    ConfigurationRepository config = ConfigurationRepository();
    configuration = await config.loadConfig();
  }

  factory ConfigManager() {
    return _singleton;
  }

  Iterable<String> getKey() {
    if (configuration == null)
      return [];
    return configuration!.keys;
  }

  void saveConfig() async {
    ConfigurationRepository config = ConfigurationRepository();
    if (configuration!=null) config.saveConfig(configuration!);
  }

  ConfigManager._internal();


}