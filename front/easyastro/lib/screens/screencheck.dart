import 'package:flutter/material.dart';
import 'package:easyastro/repositories/observablerepositories.dart';
import 'package:easyastro/services/location/locationhelper.dart';
import 'package:easyastro/services/database/globals.dart';
import 'package:easyastro/components/structure/pagestructure.dart';
import 'package:easyastro/astro/astrocalc.dart';
import 'package:easyastro/services/database/configmanager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:geolocator/geolocator.dart';

class CheckScreen extends StatefulWidget {
  const CheckScreen({super.key});

  @override
  _CheckScreen createState() => _CheckScreen();
}

class _CheckScreen extends State<CheckScreen> {
  Position? _locationData;
  bool _apiUpdated = false;
  bool _catalogUpdated = false;

  Future<void> updateDescription() async {
    for (var element in ObjectSelection().selection) {
      element.description = element.name.tr();
    }
  }

  void updateLocale(String key, dynamic value) async {
    switch (value) {
      case ('FR'):
        {
          await context.setLocale(const Locale('fr', 'FR'));
        }
        break;
      case ('EN'):
        {
          await context.setLocale(const Locale('en', 'US'));
        }
        break;
      default:
        {
          await context.resetLocale();
          await updateDescription();
        }
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    ConfigManager().loadConfig().then((value) {
      ConfigManager().addCallBack("language", updateLocale);
      updateLocale("", ConfigManager().configuration!['language']!.value);
      _getLocation();
    });
  }

  Future<void> _getLocation() async {
    Position? locationData;
    LocationHelper locationHelper = LocationHelper();

    await AstroCalc.init();
    setState(() {
      _locationData = null; // Afficher le message d'attente
    });

    locationData = await locationHelper.getLocation();
    CurrentLocation().longitude = locationData.longitude;
    CurrentLocation().latitude = locationData.latitude;
    CurrentLocation().altitude = locationData.altitude;

    setState(() {
      _locationData = locationData; // Afficher la position GPS
    });

    //await locationHelper.updateAPILocation();
    setState(() {
      _apiUpdated = true;
    });
    ObservableRepository catalog = ObservableRepository();
    if (_locationData != null) {
      ObjectSelection().selection = await catalog.fetchCatalogList(
          _locationData?.longitude,
          _locationData?.latitude,
          _locationData?.altitude,
          null);
    } else {
      ObjectSelection().selection =
          await catalog.fetchCatalogList(0, 0, 0, null);
    }
    setState(() {
      _catalogUpdated = true;
    });
    //await Future.delayed(const Duration(seconds:3));
    //ConfigManager().loadConfig().then(() => Navigator.pushNamed(context, '/home'));
    /* await Future.delayed(const Duration(seconds:3)); // Attendre 3 secondes
    print('#####"');
    print(ConfigManager().configuration);
    if (ConfigManager().configuration!=null) {
      ConfigManager().configuration?["manageTelescope"];
      print(ConfigManager().getKey());
      print(ConfigManager().configuration!['manageTelescope']!.value);
      ConfigManager().configuration!['manageTelescope']!.value = true;
      ConfigManager().saveConfig();
    }*/
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return PageStructure(
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
          const Center(child: CircularProgressIndicator()),
          Center(
              child: _locationData != null &&
                      _locationData?.latitude != null &&
                      _locationData?.longitude != null
                  ? const Text('position').tr(args: [
                      _locationData!.latitude.toString(),
                      _locationData!.longitude.toString(),
                      _locationData!.altitude.toString()
                    ]) //'Position : ${_locationData?.latitude}, ${_locationData?.longitude}, ${_locationData?.altitude}')
                  : const Text('waiting_position').tr()),
          Center(
              child: _apiUpdated == false
                  ? const Text('waiting_position').tr()
                  : const Text('api_updated').tr()),
          Center(
              child: _apiUpdated == false
                  ? const Text('wating_catalog').tr()
                  : const Text('catalog_updated').tr()),
        ]));
  }
}
