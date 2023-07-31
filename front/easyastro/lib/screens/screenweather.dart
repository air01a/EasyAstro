import 'package:flutter/material.dart';
import 'package:easyastro/components/structure/pagestructure.dart';
import 'package:easyastro/models/weathermodel.dart';
import 'package:easyastro/services/database/globals.dart';
import 'package:easyastro/astro/astrocalc.dart';
import 'package:easyastro/services/database/configmanager.dart';
import 'package:easy_localization/easy_localization.dart';



class  ScreenWeather extends StatefulWidget {
  const ScreenWeather({super.key});

  @override
   _ScreenWeather createState() => _ScreenWeather();
}


class _ScreenWeather extends State<ScreenWeather> {
  AstroCalc? astro = ObjectSelection().astro;
  dynamic weather;
  WeatherModel? lWeather;

    @override
  void initState() {
    super.initState();
    String? openWeatherKey = ConfigManager().configuration?["openWeatherKey"]?.value;
    if (openWeatherKey!=null && openWeatherKey.isNotEmpty) {


      lWeather = WeatherModel(openWeatherKey);
      
      lWeather!.getLocationForecast(astro!.longitude, astro!.latitude).then((value) => setState(() => weather = value));

    }
    
  }


  @override
  Widget build(BuildContext context) {

    List<Widget> forecast = [];

    if (weather==null) return Container();
    weather["list"].forEach((weatherItem) {
      int time = weatherItem["dt"];
      int condition = weatherItem["weather"][0]["id"];
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(time * 1000);
      String formattedDate = DateFormat('yyyy/MM/dd').format(dateTime);
      String formattedHour = DateFormat('HH:MM').format(dateTime);
      forecast.add(Column(children: [
                    
                    Text(formattedDate),
                    Text(formattedHour),
                    SizedBox(width: 20, child: 
                    Align(
                      alignment: Alignment.center,
                      child: Text(style: const TextStyle(fontSize: 20), lWeather!.getWeatherIcon(condition)))),
           ]));

    });
    return PageStructure(
              body:GridView.count(
        primary: false,
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        crossAxisCount: 4,
        children: forecast),
              showDrawer: false,
              title: "weather_next_days".tr());
  }
}