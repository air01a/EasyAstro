import 'package:flutter_osm_plugin/flutter_osm_plugin.dart'; 
import 'package:flutter/material.dart';
import 'package:easyastro/components/pagestructure.dart';


  class SetLocation extends StatefulWidget {
  @override
  State<SetLocation> createState() => _SetLocation();
}

class _SetLocation extends State<SetLocation> {
  
final mapController = MapController.withPosition(
            initPosition: GeoPoint(
              latitude: 47.4358055,
              longitude: 8.4737324,
          ),
);

  @override
  Widget build(BuildContext context) {
     
      return PageStructure(
      body:Row(children: [Container(width:500,child:OSMFlutter( 
        controller: mapController,
        /*userTrackingOption: UserTrackingOption.withoutUserPosition(
          enableTracking: true,
          unFollowUser: true,
        ),*/
        initZoom: 4,
        minZoomLevel: 4,
        maxZoomLevel: 14,
        stepZoom: 1.0,
        userLocationMarker: UserLocationMaker(
            personMarker: MarkerIcon(
                icon: Icon(
                    Icons.location_history_rounded,
                    color: Colors.red,
                    size: 48,
                ),
            ),
            directionArrowMarker: MarkerIcon(
                icon: Icon(
                    Icons.double_arrow,
                    size: 48,
                ),
            ),
        ),
         roadConfiguration: RoadOption(
                roadColor: Colors.yellowAccent,
        ),
        markerOption: MarkerOption(
            defaultMarker: MarkerIcon(
                icon: Icon(
                  Icons.person_pin_circle,
                  color: Colors.blue,
                  size: 56,
                  ),
                )
        ),
    )),ElevatedButton(onPressed: (){print("cliqué");mapController.advancedPositionPicker(); mapController.getCurrentPositionAdvancedPositionPicker().then((v)=>print(v));;}, child: Icon(Icons.location_on))
    ]));

  }
}