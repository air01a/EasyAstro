import 'package:flutter/material.dart';
import 'package:easyastro/components/structure/pagestructure.dart';
import 'package:easyastro/services/database/globals.dart';
import 'package:easyastro/astro/astrocalc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easyastro/services/skymap/displaysolarsystemhelper.dart';

class ScreenMoonCalendar extends StatelessWidget {
  AstroCalc? astro = ObjectSelection().astro;
  DisplaySolarSystemHelper solarSystemHelper = DisplaySolarSystemHelper();

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    int currentDay = now.day; 
    int currentMonth = now.month; 
    //int currentDayOfWeek = now.weekday;
    


    List<Widget> forecast = [];

    /*
    weather["list"].forEach((weatherItem) {
      int time = weatherItem["dt"];
      int condition = weatherItem["weather"][0]["id"];
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(time * 1000);
      String formattedDate = DateFormat('yyyy/MM/dd').format(dateTime);
      String formattedHour = DateFormat('HH:MM').format(dateTime);
      forecast.add(Column(children: [
        Text(formattedDate),
        Text(formattedHour),
        SizedBox(
            width: 20,
            child: Align(
                alignment: Alignment.center,
                child: Text(
                    style: const TextStyle(fontSize: 20),
                    lWeather!.getWeatherIcon(condition)))),
      ]));
    });*/
    return PageStructure(
        body: GridView.count(
            primary: false,
            padding: const EdgeInsets.all(20),
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
            crossAxisCount: 4,
            children: forecast),
        showDrawer: false,
        title: "moon_calendar".tr());
  }
}
