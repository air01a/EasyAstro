import 'package:flutter/material.dart';
import 'package:easyastro/components/pagestructure.dart';
import 'package:easyastro/astro/astrocalc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:easyastro/services/globals.dart';
import 'package:sweph/sweph.dart';
import 'package:easyastro/components/selectdate.dart'; 
import 'package:easyastro/components/setlocation.dart'; 
import 'package:easyastro/models/weathermodel.dart';
import 'package:geopoint/geopoint.dart';

class  ScreenHome extends StatefulWidget {
 

  @override
   _ScreenHome createState() => _ScreenHome();
}


class _ScreenHome extends State<ScreenHome> {
  AstroCalc? astro = ObjectSelection().astro;


  double getSize() {
    if (kIsWeb) {
      return 200;
    }
    return 150;
  }

  Image getMoonImage(int imageNumber) {
    Image currentImage;
    imageNumber = (imageNumber * 24/28 % 24).toInt();

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
            currentImage = Image.network("assets/appimages/Sun.jpg", width:getSize());
        } else {
            currentImage = Image(image:AssetImage("assets/appimages/Sun.jpg"), width: getSize());
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

  List<Widget> getTimeText() {
      List<Widget> display = [];
      display.add(Text("Date : ${ObjectSelection().astro!.getDate()}"));
      display.add(Text("Hour : ${ConvertAngle.hourToString(ObjectSelection().astro!.hour)}"));
      display.add(Text("Sidereal : ${ConvertAngle.hourToString(ObjectSelection().astro!.getSiderealTime())}"));
      display.add(Text("\nclick to change"));
      return display;
  }

  void setNewLocation(GeoPoint p) {
    print(p);
    if (p!=null) {

        CurrentLocation().longitude = p.longitude ;
        CurrentLocation().latitude = p.latitude;
        CurrentLocation().altitude = 0;
        setState(() {
          astro!.setPosition(p.longitude,p.latitude,0);
        },);
        
        print("change donne");
    }
  }

  @override
  void initState() {
    super.initState();
    WeatherModel test = WeatherModel();
    //test.getLocationWeather(astro!.longitude, astro!.latitude);
  }


  @override
  Widget build(BuildContext context) {
    AstroCalc? astro = ObjectSelection().astro;
  List<Widget> display=[];
  List<Widget> displaySun=[];
  List<Widget> displayLocation=[];
  List<Widget> displayTime=[];  
  List<Widget> displayTimeText = [];
    displayTime=[];    
    if (astro!=null) {

      // Get moon card with all informations
      List<int> moonPhase = astro!.getMoonPhase();
      List<Widget> displayMoon = [];
      AstroCoordinates moon = astro!.getObjectCoord(HeavenlyBody.SE_MOON);
      final ephemeris = astro!.calculateEphemeris(moon.ra, moon.dec, astro.getSiderealTime());
      display.add(getMoonImage(moonPhase[1]));
      displayMoon.add(Text("Illumination : ${moonPhase[0]} %"));
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
      displayLocation.add(GestureDetector(onTap: () async{  var p = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LocationSearchPage(),
                ),
              ); 
              if (p!=null) setNewLocation(p);},
        child: Container(width: getSize(), child: Icon(Icons.location_on, size: getSize()/2))));
      List<Widget> displayLocationText = [];
      displayLocationText.add(Text("Longitude : ${astro!.longitude}"));
      displayLocationText.add(Text("Latitude : ${astro!.latitude}"));
      displayLocationText.add(Text("Altitude : ${astro!.altitude}"));
      displayLocation.add(Column(mainAxisSize :MainAxisSize.min,children:displayLocationText));

      displayTimeText = getTimeText();
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
                                getCard([GestureDetector(
                                    onTap: ()  => { SelectDate.selectDate(context, DateTime.parse(astro!.getDate()), TimeOfDay.fromDateTime(DateTime.parse(astro!.getDate()))).then((value) {
                                              setState(()  { 
                          
                                                    displayTimeText = getTimeText();});})            
                                     },
                                      child: Container(width: getSize(), child: Icon(Icons.schedule, size: getSize()/2)) ),
                                      Column(mainAxisSize :MainAxisSize.min,children:displayTimeText)]
                                )
                ])
   )))));
  }
}

