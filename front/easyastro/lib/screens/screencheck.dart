import 'package:flutter/material.dart';
import 'package:easyastro/repositories/observablerepositories.dart';
import 'package:easyastro/services/location/locationhelper.dart';
import 'package:easyastro/services/database/globals.dart';
import 'package:easyastro/components/structure/pagestructure.dart';
import 'package:easyastro/astro/astrocalc.dart';
import 'package:easyastro/services/database/configmanager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:geolocator/geolocator.dart';
import 'package:easyastro/services/catalog/catalogupdater.dart';


class CheckScreen extends StatefulWidget {
  const CheckScreen({super.key});

  @override
  State<CheckScreen> createState() => _CheckScreen();
}

class _CheckScreen extends State<CheckScreen> {
  Position? _locationData;
  bool _apiUpdated = false;
  double catalogUpdateProgress=0;

  Future<void> updateDescription() async {
    for (var element in ObjectSelection().selection) {
      element.description = element.name.tr();
    }
  }


  void loadingCatalogProgess(double percent) {
    setState(() {
      catalogUpdateProgress=percent;
    });
    

  }
  void updateLocale(String key, dynamic value) async {
    if (value == "system") {
      value = Intl.systemLocale.toLocale().languageCode.toUpperCase();
    }
    switch (value) {
      case ('FR'):
        {
          if (mounted) {
            await EasyLocalization.of(context)!
                .setLocale(const Locale('en', ''));
                // Only to remove warning from flutter
                if (mounted) {
                  await EasyLocalization.of(context)!
                      .setLocale(const Locale('fr', ''));
                }
          }
        }
        break;
      case ('EN'):
        {
          if (mounted) {
            await EasyLocalization.of(context)!
                .setLocale(const Locale('fr', ''));
                // Only to remove warning from flutter
                if (mounted) {
                  await EasyLocalization.of(context)!
                      .setLocale(const Locale('en', ''));
                }
          }
        }
        break;
      default:
        {
          if (mounted) {
            await EasyLocalization.of(context)!
                .setLocale(const Locale('fr', ''));
                if(mounted) {
                    await EasyLocalization.of(context)!
                        .setLocale(const Locale('en', ''));
                }
          }
        }
        break;
    }
    await updateDescription();
  }

  @override
  void initState() {
    super.initState();

    ConfigManager().loadConfig().then((value) {
      CatalogUpdater updater = CatalogUpdater(ConfigManager().configuration!['remoteCatalog']!.value,loadingCatalogProgess);
      updater.checkAndUpdateVersion().then((result) {
        catalogUpdateProgress=1.0;
        ConfigManager().addCallBack("language", updateLocale);
        updateLocale("", ConfigManager().configuration!['language']!.value);
        _getLocation();
      });
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
    setState(() {});
    if (mounted) Navigator.pushReplacementNamed(context, '/home');
  }

  @override
Widget build(BuildContext context) {
    return PageStructure(
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
          const Center(child: CircularProgressIndicator()),
          Center(
            child:Center(child:Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                  const Text("catalog_updater").tr(),
                  const SizedBox(width: 5),
                  SizedBox(
                      width: 100,
                      child: LinearProgressIndicator(
                          value: catalogUpdateProgress, // Valeur de la progression
                        )
                   )
              ]))),
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
