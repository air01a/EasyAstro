
import 'package:easyastro/services/database/localstoragehelper.dart';
import 'package:easyastro/models/configmodel.dart';

class ConfigurationRepository {
  Map<String, ConfigItem> defaultConfig = {'manageTelescope':ConfigItem('manageTelescope', 'manage_telescope', 'checkbox', false, []),
                                           'openWeatherKey':ConfigItem('openWeatherKey', 'ow_api_key', 'input', "", []),
                                           'imageRatio':ConfigItem('Image ratio when edit', 'image_ratio', 'input', "0.5", []),
                                           'language':ConfigItem('Language', 'language', 'select','system',['system','FR','EN'])};
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

      _ls.addSelection(config, id:'main');
  }
}
