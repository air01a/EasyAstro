import 'package:flutter/material.dart';
import 'package:front_test/repositories/observablerepositories.dart';
import 'package:front_test/services/servicecheck.dart';
import 'package:location/location.dart';
import 'package:front_test/services/globals.dart';


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

    setState(() {
      _locationData = null; // Afficher le message d'attente
    });

    locationData = await checkHelper.getLocation();
    setState(() {
      _locationData = locationData; // Afficher la position GPS
    });

    await checkHelper.updateAPILocation();
    setState(() {
      _apiUpdated = true;
    });
    ObservableRepository catalog = ObservableRepository();
    ObjectSelection().selection = await catalog.fetchCatalogList();
    setState(() {
      _catalogUpdated = true;
    });

    await Future.delayed(const Duration(seconds: 3)); // Attendre 3 secondes
    Navigator.pushNamed(context, '/home');
    
  }

  @override
  Widget build(BuildContext context) {
    return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:<Widget>[
                            Center(
                                      child: _locationData != null && _locationData?.latitude!=null && _locationData?.longitude!=null
                                  ? Text('Position : ${_locationData?.latitude}, ${_locationData?.longitude}, ${_locationData?.altitude}')
                                  : Text('Attente de la position GPS...')),
                            Center(child: _apiUpdated == false
                                   ? Text('Waiting to update position')
                                   : Text('API Updated')
                            ),
                            Center(child: _apiUpdated == false
                                   ? Text('Waiting to update catalog')
                                   : Text('catalog Updated')
                            )
    ]);
  }
}