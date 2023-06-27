import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:easyastro/models/catalogs.dart';
import 'package:easyastro/astro/astrocalc.dart';
import 'package:sweph/sweph.dart';
import 'package:easyastro/services/globals.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

double raToDouble(String ra) {

  double ret = 0.0;int divisor = 1;int multiplicator=15;
  ra.split(':').forEach((element){
    ret += double.parse(element)/divisor*multiplicator;
    divisor *= 60;
    multiplicator = 1;  
  });
  return ret;
}

double decToDouble(String ra) {

  double ret = 0.0;int divisor = 1;
  ra.substring(1).split(':').forEach((element){
    ret += double.parse(element)/divisor;
    divisor *= 60;
  });
  if (ra[0]=='-') {
    ret *= -1;
  }
  return ret;
}

Future<Map<String,String>> getDescription(String language) async {
  Map<String, String> dataMap = {};
  var description = await rootBundle.loadString(
      "assets/data/description_en",
    );
  List<String> lines = description.split('\n');
  for (String line in lines) {
    List<String> parts = line.split('|');
    if (parts.length >= 2) {
      String name = parts[0].trim();
      String description = parts[1].trim();

      // Stockez les valeurs dans la hashtable (Map)
      dataMap[name] = description;
    }
  }
  return dataMap;
}


Future<List<Map<String, dynamic>>> openCatalog(double lon, double lat, double alt, String? time)  async {
    AstroCalc astro = AstroCalc();

    astro.setPosition(lon, lat, alt);
    if (time!=null) {
      print(time);
      final now = DateTime.parse(time);
      int day = now.day;
      int month = now.month;
      int year = now.year;
      double hour = now.hour + now.minute/60 + now.second / 3600;
      astro.setDate(year, month, day, hour);
    }
    double st = astro.getSiderealTime();

    ObjectSelection().astro = astro;
    //Map<String,String> descriptions = await getDescription('en');
    var result = await rootBundle.loadString(
      "assets/data/deepsky.lst",
    );
    
    List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(result, fieldDelimiter: ";", eol: "\n", textDelimiter: '"');
    List<String> columnNames = List.from(rowsAsListOfValues.removeAt(0));
    List<Map<String, dynamic>> jsonData = [];

    bool sunIsVisible = false;
    for (var row in rowsAsListOfValues) {
      Map<String, dynamic> data = {};
      for (var i = 0; i < columnNames.length; i++) {
        data[columnNames[i]] = row[i];
      }
      if (data['TYPE']==0) {
        data['RA deg']=raToDouble(data['RA']);
        data['DEC deg']=decToDouble(data['DEC']);
      } else {
        HeavenlyBody? body = astro.getObjectName(data['NAME']); 
        if (body != null) {
          AstroCoordinates coord = astro.getObjectCoord(body);
          data['RA deg']=coord.ra;
          data['DEC deg']=coord.dec;
        } else {
          data['RA deg'] = 0;
          data['DEC deg'] = 0;
        }
      }
 //     if (!sunIsVisible || data['NAME']=='Moon') {
          EphemerisParameters ephemeris = astro.calculateEphemeris(data['RA deg'],  data['DEC deg'], st);
    //      if (ephemeris.visible) {
              //print(data['NAME']);print("${ephemeris.rising} ${ephemeris.setting} ${ephemeris.culmination}");
              //print("${data['RA']} - ${data['RA deg']}/ ${data['DEC']} - ${data['DEC deg']}");
              data['meridian_time']=ephemeris.culmination;
              data['timeToMeridian']=ephemeris.culmination-astro.hour;
              data['height']=ephemeris.height;
              if (data['timeToMeridian']<-12.0) data['timeToMeridian']+=24;

              data['rise'] = ephemeris.rising;
              data['set']  = ephemeris.setting;
              //data['description'] = descriptions[data['NAME']];

              data['visible'] = ephemeris.visible;
              if (sunIsVisible && data['NAME']!='Moon') data['visible'] = false;

              jsonData.add(data);
              if (data['NAME']=='Sun' && ephemeris.visible) {
                sunIsVisible = true;
              }
              //astro.getAzimutalChart(data['RA deg'], data['DEC deg'], st);
          }
  //    }
  //  }

    ObservableObjects.fromJson(jsonData).catalog;
    return jsonData;
  }


