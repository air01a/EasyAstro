import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_localization/easy_localization.dart';


class Compass extends StatefulWidget {
  const Compass({super.key});

  @override
  State<Compass> createState() => _Compass();
}

class _Compass extends State<Compass> {
  bool _hasPermissions = false;
  CompassEvent? _lastRead;

  @override
  void initState() {
    _fetchPermissionStatus();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return  Builder(builder: (context) {
          if (_hasPermissions) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  _buildValues(),
                  Expanded(child: _buildCompass()),
                ],
              ),
            );
          } else {
            return _buildPermissionSheet();
          }
        });
  
  }

  Widget _buildValues() {

    int heading;
    heading = _lastRead?.heading?.toInt() ?? 0;
    if ( heading<0) {
      heading += 360;
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(child:Text('heading',
                    style: Theme.of(context).textTheme.bodySmall,
                  ).tr(args:[heading.toString()])),
                  
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        updateCompassValues();
        if (snapshot.hasError) {
          return Text('Error reading heading: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        double? direction = snapshot.data!.heading;

        if (direction == null) {
          return const Center(
            child: Text("Device does not have sensors !"),
          );
        }

        return Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4.0,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white
            ),
            child: Transform.rotate(
              angle: (direction * (math.pi / 180) * -1),
              child: Image.asset('assets/appimages/compass.png'),
            ),
          ),
        );
      },
    );
  }

  void updateCompassValues() async {
    final CompassEvent tmp = await FlutterCompass.events!.first;
    setState(() {
      _lastRead = tmp;
    });
  }

  Widget _buildPermissionSheet() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('Location Permission Required'),
          ElevatedButton(
            child: const Text('Request Permissions'),
            onPressed: () {
              Permission.locationWhenInUse.request().then((ignored) {
                _fetchPermissionStatus();
              });
            },
          ),
        ],
      ),
    );
  }

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() => _hasPermissions = status == PermissionStatus.granted);
      }
    });
  }
}