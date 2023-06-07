import 'package:flutter/material.dart';
import 'package:easyastro/repositories/observablerepositories.dart';
import 'package:easyastro/services/servicecheck.dart';
import 'package:location/location.dart';
import 'package:easyastro/services/globals.dart';
import 'package:easyastro/components/pagestructure.dart';
import 'package:easyastro/astro/astrocalc.dart';

class CheckScreen extends StatefulWidget {
  @override
  _CheckScreen createState() => _CheckScreen();
}

class _CheckScreen extends State<CheckScreen> {
  LocationData? _locationData;
  bool _apiUpdated=false;
  bool _catalogUpdated = false; 

  @override
  void initState() {
    super.initState();
    _getLocation();
  }


  Future<void> _getLocation() async {
    LocationData? locationData;
    ServiceCheckHelper checkHelper = ServiceCheckHelper();
    
    
    await AstroCalc.init();
    setState(() {
      _locationData = null; // Afficher le message d'attente
    });

    locationData = await checkHelper.getLocation();
    if (locationData != null)
    {
      CurrentLocation().longitude = locationData.longitude;
      CurrentLocation().latitude = locationData.latitude;
      CurrentLocation().altitude = locationData.altitude;
    }

    setState(() {
      _locationData = locationData; // Afficher la position GPS
    });

    //await checkHelper.updateAPILocation();
    setState(() {
      _apiUpdated = true;
    });
    ObservableRepository catalog = ObservableRepository();
    if (_locationData!=null) {
      ObjectSelection().selection = await catalog.fetchCatalogList(_locationData?.longitude, _locationData?.latitude, _locationData?.altitude, null);
    } else {
      ObjectSelection().selection = await catalog.fetchCatalogList(0, 0, 0,null);
    }
    setState(() {
      _catalogUpdated = true;
    });

    await Future.delayed(const Duration(seconds: 0)); // Attendre 3 secondes
    Navigator.pushNamed(context, '/home');
    
  }

  @override
  Widget build(BuildContext context) {
    return PageStructure(
            body: 
              Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:<Widget>[
                            const Center(child: CircularProgressIndicator()),

                            Center(
                                      child: _locationData != null && _locationData?.latitude!=null && _locationData?.longitude!=null
                                  ? Text('Position : ${_locationData?.latitude}, ${_locationData?.longitude}, ${_locationData?.altitude}')
                                  : const Text('Attente de la position GPS...')),
                            Center(child: _apiUpdated == false
                                   ? const Text('Waiting to update position')
                                   : const Text('API Updated')
                            ),
                            Center(child: _apiUpdated == false
                                   ? const Text('Waiting to update catalog')
                                   : const Text('catalog Updated')
                            ),
                            
          ]));
  }
}