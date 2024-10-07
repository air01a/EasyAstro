import 'package:easyastro/services/database/localstoragehelper.dart';
import 'package:easyastro/models/configmodel.dart';

class ConfigurationRepository {
  Map<String, ConfigItem> defaultConfig = {
    'manageTelescope': ConfigItem(
        'manageTelescope', 'manage_telescope', 'checkbox', false, []),
    'minHeight':
        ConfigItem('minHeight', 'min_height', 'input', "30", []),
    'openWeatherKey':
        ConfigItem('openWeatherKey', 'ow_api_key', 'input', "", []),
    'imageRatio':
        ConfigItem('Image ratio when edit', 'image_ratio', 'input', "0.5", []),
    'language': ConfigItem(
        'Language', 'language', 'select', 'system', ['system', 'FR', 'EN']),
    'mapShowDSO':
        ConfigItem('mapShowDSO', 'map_show_dso', 'checkbox', true, []),
    'mapShowOnlySelected': ConfigItem(
        'mapShowOnlySelected', 'map_show_only_selected', 'checkbox', false, []),
    'mapShowStarNames':
        ConfigItem('mapShowLines', 'map_show_starname', 'checkbox', true, []),
    'mapShowLines':
        ConfigItem('mapShowLines', 'map_show_lines', 'checkbox', true, []),
    'showAltAzMaxExpo': ConfigItem(
        'showAltAzMaxExpo', 'show_alt_az_max_expo', 'checkbox', false, []),
    'sensor_diag':
        ConfigItem('Sensor diagonal', 'sensor_diag', 'input', "14.1", []),
    'pixel_size': ConfigItem('Pixel size', 'pixel_size', 'input', "3.35", []),
    'azimuth': ConfigItem('azimuth', 'azimuth_selector', 'azimuth', List.generate(36, (index) => true), []),
    'remoteCatalog': ConfigItem('remoteCatalog','remote_catalog', 'input', 'https://www.easyastro.net/application/catalog/',[]),
  };
  final _ls = LocalStorage('Configuration');

  Future<Map<String, ConfigItem>> loadConfig() async {
    Map<String, ConfigItem> result = {};
    Map<String, dynamic>? cnf = await _ls.getSelection('main');
    if (cnf != null) {
      cnf.forEach((key, value) {
        ConfigItem item = ConfigItem.fromJson(value);
        result[key] = item;
      });

      defaultConfig.forEach((key, value) {
        if (!result.containsKey(key)) {
          result[key] = value;
        }
      });
    } else {
      result = defaultConfig;
    }

    return result;
  }

  Future<void> saveConfig(Map<String, ConfigItem> config) async {
    _ls.addSelection(config, id: 'main');
  }
}
