
import 'package:easyastro/services/localstoragehelper.dart';
import 'package:easyastro/models/configmodel.dart';
class ConfigurationRepository {
  Map<String, ConfigItem> defaultConfig = {'manageTelescope':ConfigItem('manageTelescope', 'Manage telescope', 'checkbox', false, []),
                                           'openWeatherKey':ConfigItem('openWeatherKey', 'OpenWeather api key', 'input', "", [])};
  final _ls = LocalStorage('Configuration');

  Future<Map<String,ConfigItem>> loadConfig() async {
    
    Map<String, ConfigItem> result = {};
    Map<String, dynamic>? cnf = await _ls.getSelection('main');
    if (cnf!=null) {
      cnf.forEach((key, value) {
        ConfigItem item = ConfigItem.fromJson(value);
        result[key]=item;
      });

      defaultConfig.forEach((key, value) {
        if (!result.containsKey(key)) {
            result[key] = value;
        }});
    } else {
      result = defaultConfig;
    }
    return result;
  }

  Future<void> saveConfig(Map<String, ConfigItem> config) async {
    print(config);
      _ls.addSelection(config, id:'main');
  }
}
