import 'package:flutter/material.dart';
import 'package:front_test/components/pagestructure.dart';
import 'package:front_test/astro/astrocalc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:front_test/services/globals.dart';
import 'package:sweph/sweph.dart';

class  ScreenHome extends StatefulWidget {
 

  @override
   _ScreenHome createState() => _ScreenHome();
}


  
  /*Image.asset(
  "assets/appimages/moon_phase.jpg",
// move on the X axis to right 10% of the image and 0% on the Y Axis
   alignment: const Alignment(0.1,0),
// set fit to none
   fit: BoxFit.none,
// use scale to zoom out of the image
   scale: 2,);
*/
class _ScreenHome extends State<ScreenHome> {
  final astro = ObjectSelection().astro;
  
  double getSize() {
    if (kIsWeb) {
      return 200;
    }
    return 150;
  }

  Image getMoonImage(int percent) {
    int imageNumber = (percent/7.8+1).toInt(); 
    Image currentImage;
    if (kIsWeb) {
            currentImage = Image.network("assets/appimages/moon$imageNumber.png", width:getSize());

        } else {
            currentImage = Image(image:AssetImage("assets/appimages/moon$imageNumber.png"), width: getSize());

        }


    return currentImage;
  }


  Image getSunImage() {
Image currentImage;
    if (kIsWeb) {
            currentImage = Image.network("assets/appimages/sun.jpg", width:200);

        } else {
            currentImage = Image(image:AssetImage("assets/appimages/sun.jpg"), width: 180);

        }


    return currentImage;

  }

  Widget getCard(List<Widget> content) {
    return SizedBox(
                width: 400,
                height: getSize(),
                child:Card(
                          shape: StadiumBorder(
                            side: BorderSide(
                              // border color
                              color: Color.fromARGB(255, 43, 46, 48),
                              // border thickness
                              width: 5,
                            ),
                          ),
                          color: Theme.of(context).primaryColor,
                          clipBehavior: Clip.hardEdge,
                            child:Row(
                              mainAxisAlignment: MainAxisAlignment.start, 
                              children: content
                            )
              ));
     
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> display=[];
    List<Widget> displaySun=[];
    List<Widget> displayLocation=[];
    List<Widget> displayTime=[];    
    if (astro!=null) {

      // Get moon card with all informations
      int moonPhase = astro!.getMoonPhase();
      List<Widget> displayMoon = [];
      AstroCoordinates moon = astro!.getObjectCoord(HeavenlyBody.SE_MOON);
      final ephemeris = astro!.calculateEphemeris(moon.ra, moon.dec, astro!.getSiderealTime());
      display.add(getMoonImage(moonPhase));
      displayMoon.add(Text("Illumination : $moonPhase %"));
      displayMoon.add(Text("Rise : ${ConvertAngle.hourToString(ephemeris.rising)}"));
      displayMoon.add(Text("Set : ${ConvertAngle.hourToString(ephemeris.setting)}"));
      displayMoon.add(Text("Culmination : ${ConvertAngle.hourToString(ephemeris.culmination)}"));
      display.add(Column(mainAxisSize :MainAxisSize.min, children: displayMoon,));


      // Get Sun card with all informations
      AstroCoordinates sun = astro!.getObjectCoord(HeavenlyBody.SE_SUN);
      final ephemerisSun = astro!.calculateEphemeris(sun.ra, sun.dec, astro!.getSiderealTime());
      displaySun.add(getSunImage());
      List<Widget> displaySunText = [];
      displaySunText.add(Text("Rise : ${ConvertAngle.hourToString(ephemerisSun.rising)}"));
      displaySunText.add(Text("Set : ${ConvertAngle.hourToString(ephemerisSun.setting)}"));
      displaySunText.add(Text("Culmination : ${ConvertAngle.hourToString(ephemerisSun.culmination)}"));
      displaySun.add(Column(mainAxisSize :MainAxisSize.min,children: displaySunText,));

      // Display Position
      displayLocation.add(Icon(Icons.location_on, size: getSize()/2));
      List<Widget> displayLocationText = [];
      displayLocationText.add(Text("Longitude : ${astro!.longitude}"));
      displayLocationText.add(Text("Latitude : ${astro!.latitude}"));
      displayLocationText.add(Text("Altitude : ${astro!.altitude}"));
      displayLocation.add(Column(mainAxisSize :MainAxisSize.min,children:displayLocationText));

      displayTime.add(Icon(Icons.schedule, size: getSize()/2));
      List<Widget> displayTimeText = [];
      displayTimeText.add(Text("Date : ${astro!.getDate()}"));
      displayTimeText.add(Text("Hour : ${ConvertAngle.hourToString(astro!.hour)}"));
      displayTimeText.add(Text("Sidereal : ${ConvertAngle.hourToString(astro!.getSiderealTime())}"));
      displayTime.add(Column(mainAxisSize :MainAxisSize.min,children:displayTimeText));
    }
    if (display.isEmpty) display.add(Container());

    return PageStructure(
      body:Center(
            child: SingleChildScrollView(

              child: IntrinsicHeight(
                child: Container(
                          width: double.infinity,
                          child: Wrap(
                              alignment : WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              direction: Axis.horizontal,
                              spacing: 40,
                              children: [
                                getCard(displaySun),
                                getCard(display),
                                getCard(displayLocation),
                                getCard(displayTime)
                  
                ])
   )))));
  }
}

