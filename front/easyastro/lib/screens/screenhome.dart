import 'package:flutter/material.dart';
import 'package:easyastro/components/structure/pagestructure.dart';
import 'package:easyastro/astro/astrocalc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:easyastro/services/database/globals.dart';
import 'package:sweph/sweph.dart';
import 'package:easyastro/components/forms/selectdate.dart';
import 'package:easyastro/components/forms/setlocation.dart';
import 'package:easyastro/models/weathermodel.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:easyastro/services/database/configmanager.dart';
import 'package:easyastro/services/location/locationhelper.dart';
import 'package:easyastro/screens/screenweather.dart';
import 'package:easy_localization/easy_localization.dart';

class ScreenHome extends StatefulWidget {
  const ScreenHome({super.key});

  @override
  State<ScreenHome> createState() => _ScreenHome();
}

class _ScreenHome extends State<ScreenHome> {
  AstroCalc? astro = ObjectSelection().astro;
  LocationHelper locationHelper = LocationHelper();
  dynamic weather;
  WeatherModel? lWeather;
  double longitude = 0;
  double latitude = 0;
  double altitude = 0;
  List<Widget> displayTimeText = [];

  double getSize() {
    if (kIsWeb) {
      return 200;
    }
    return 150;
  }

  Image getMoonImage(int imageNumber) {
    Image currentImage;
    imageNumber = (imageNumber * 24 / 28 % 24).toInt();

    if (kIsWeb) {
      currentImage = Image.network("assets/appimages/moon$imageNumber.png",
          width: getSize());
    } else {
      currentImage = Image(
          image: AssetImage("assets/appimages/moon$imageNumber.png"),
          width: getSize());
    }
    return currentImage;
  }

  Image getSunImage() {
    Image currentImage;
    if (kIsWeb) {
      currentImage =
          Image.network("assets/appimages/Sun.jpg", width: getSize());
    } else {
      currentImage = Image(
          image: const AssetImage("assets/appimages/Sun.jpg"),
          width: getSize());
    }
    return currentImage;
  }

  Widget getCard(List<Widget> content, {Function()? onTap}) {
    Widget sb = SizedBox(
        width: 400,
        height: getSize(),
        child: Card(
            shape: const StadiumBorder(
              side: BorderSide(
                // border color
                color: Color.fromARGB(255, 43, 46, 48),
                // border thickness
                width: 5,
              ),
            ),
            color: Theme.of(context).primaryColor,
            clipBehavior: Clip.hardEdge,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: content)));
    if (onTap == null) return sb;
    return GestureDetector(onTap: onTap, child: sb);
  }

  void gotoWeather() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScreenWeather(),
      ),
    );
  }

  List<Widget> getTimeText() {
    List<Widget> display = [];
    display
        .add(const Text('date').tr(args: [ObjectSelection().astro!.getDate()]));
    display.add(const Text('hour')
        .tr(args: [ConvertAngle.hourToString(ObjectSelection().astro!.hour)]));
    display.add(const Text('sidereal').tr(args: [
      ConvertAngle.hourToString(ObjectSelection().astro!.getSiderealTime())
    ]));
    display.add(const Text("\n"));
    display.add(const Text('click_to_change').tr());
    return [
      SizedBox(
          width: getSize(), child: Icon(Icons.schedule, size: getSize() / 2)),
      SizedBox(
          width: 350 - getSize(),
          child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: display)))
    ];
  }

  void setNewLocation(GeoPoint p) {
    setState(
      () {
        astro!.setPosition(p.longitude, p.latitude, 0);
        CurrentLocation().longitude = p.longitude;
        CurrentLocation().latitude = p.latitude;
        CurrentLocation().altitude = 0;
        altitude = 0;
        longitude = p.longitude;
        latitude = p.latitude;
      },
    );
  }

  void changeLocation() async {
    var p = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationSearchPage(),
      ),
    );

    //print(" ---  $p  ----");
    if (p != null) setNewLocation(p as GeoPoint);
  }

  void setNewDate() {
    SelectDate.selectDate(context, DateTime.parse(astro!.getDate()),
            TimeOfDay.fromDateTime(DateTime.parse(astro!.getDate())))
        .then((value) {
      setState(() {
        displayTimeText = getTimeText();
      });
    });
  }

  @override
  void initState() {
    super.initState();

    String? openWeatherKey =
        ConfigManager().configuration?["openWeatherKey"]?.value;
    if (openWeatherKey != null && openWeatherKey.isNotEmpty) {
      lWeather = WeatherModel(openWeatherKey);
      lWeather!
          .getLocationWeather(astro!.longitude, astro!.latitude)
          .then((value) => setState(() => weather = value));
    }

    if (CurrentLocation().timeChanged == false) {
      locationHelper.updateTime(
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
          changeDate: false);
    }
    if (astro != null) {
      latitude = astro!.latitude;
      longitude = astro!.longitude;
      altitude = astro!.altitude;
    }
  }

  List<Widget> getWeather() {
    if ((weather == null) || (lWeather == null)) {
      return [const SizedBox(width: 0, height: 0)];
    }
    return [
      Row(children: [
        SizedBox(
            width: getSize(),
            child: Align(
                alignment: Alignment.center,
                child: Text(
                    style: TextStyle(fontSize: getSize() / 2),
                    lWeather!.getWeatherIcon(weather["weather"][0]["id"])))),
        SizedBox(
            width: 180,
            child: Text(lWeather!.getMessage(weather["weather"][0]["id"]),
                    maxLines: 2, textAlign: TextAlign.center)
                .tr())
      ])
    ];
  }

  @override
  Widget build(BuildContext context) {
   // AstroCalc? astro = ObjectSelection().astro;
    List<Widget> display = [];
    List<Widget> displaySun = [];
    List<Widget> displayLocation = [];
    displayTimeText = [];

    if (astro != null) {
      // Get moon card with all informations
      List<int> moonPhase = astro!.getMoonPhase();
      List<Widget> displayMoon = [];
      AstroCoordinates moon = astro!.getObjectCoord(HeavenlyBody.SE_MOON);
      final ephemeris =
          astro!.calculateEphemeris(moon.ra, moon.dec, astro!.getSiderealTime());
      display.add(getMoonImage(moonPhase[1]));
      displayMoon.add(const Text('illumination').tr(args: [
        moonPhase[0].toString()
      ])); //"Illumination : ${moonPhase[0]} %"));
      displayMoon.add(const Text('rise')
          .tr(args: [ConvertAngle.hourToString(ephemeris.rising)]));
      displayMoon.add(const Text('set')
          .tr(args: [ConvertAngle.hourToString(ephemeris.setting)]));
      displayMoon.add(const Text('culmination')
          .tr(args: [ConvertAngle.hourToString(ephemeris.culmination)]));
      display.add(SizedBox(
          width: 350 - getSize(),
          child: Center(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: displayMoon,
          ))));

      // Get Sun card with all informations
      AstroCoordinates sun = astro!.getObjectCoord(HeavenlyBody.SE_SUN);
      final ephemerisSun =
          astro!.calculateEphemeris(sun.ra, sun.dec, astro!.getSiderealTime());
      displaySun.add(SizedBox(width: getSize(), child: getSunImage()));
      List<Widget> displaySunText = [];
      displaySunText.add(const Text('rise')
          .tr(args: [ConvertAngle.hourToString(ephemerisSun.rising)]));
      displaySunText.add(const Text('set')
          .tr(args: [ConvertAngle.hourToString(ephemerisSun.setting)]));
      displaySunText.add(const Text('culmination')
          .tr(args: [ConvertAngle.hourToString(ephemerisSun.culmination)]));
      displaySun.add(SizedBox(
          width: 350 - getSize(),
          child: Center(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: displaySunText,
          ))));

      // Display Position
      displayLocation.add(SizedBox(
          width: getSize(),
          child: Icon(Icons.location_on, size: getSize() / 2)));
      List<Widget> displayLocationText = [];
      displayLocationText.add(
          const Text('longitude').tr(args: [longitude.toStringAsFixed(5)]));
      displayLocationText
          .add(const Text('latitude').tr(args: [latitude.toStringAsFixed(5)]));
      displayLocationText
          .add(const Text('altitude').tr(args: [altitude.toStringAsFixed(0)]));
      displayLocationText.add(const Text("\n"));
      displayLocationText.add(const Text('click_to_change').tr());
      displayLocation.add(SizedBox(
          width: 350 - getSize(),
          child: Center(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: displayLocationText))));

      displayTimeText = getTimeText();
    }
    if (display.isEmpty) display.add(Container());

    List<Widget> weatherMap = getWeather();

    return PageStructure(
        body: Center(
            child: SingleChildScrollView(
                child: IntrinsicHeight(
                    child: SizedBox(
                        width: double.infinity,
                        child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            direction: Axis.horizontal,
                            spacing: 40,
                            children: [
                              getCard(displaySun),
                              getCard(display),
                              getCard(displayLocation, onTap: changeLocation),
                              getCard(displayTimeText, onTap: setNewDate),
                              if (weather != null)
                                getCard(weatherMap, onTap: gotoWeather)
                            ]))))));
  }
}
