import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:front_test/models/catalogs.dart';
import 'package:front_test/astro/astrocalc.dart';
import 'package:sweph/sweph.dart';



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



Future<List<Map<String, dynamic>>> openCatalog(double lon, double lat, double alt, String? time)  async {
    AstroCalc astro = AstroCalc();


    astro.setPosition(lon, lat, alt);
    if (time!=null) {
      final now = DateTime.parse(time);
      int day = now.day;
      int month = now.month;
      int year = now.year;
      double hour = now.hour + now.minute/60 + now.second / 3600;
      astro.setDate(year, month, day, hour);
    }
    double st = astro.getSiderealTime();

    var result = await rootBundle.loadString(
      "/data/deepsky.lst",
    );
    
    List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(result, fieldDelimiter: ";", eol: "\n");
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
      if (!sunIsVisible || data['NAME']=='Moon') {
          EphemerisParameters ephemeris = astro.calculateEphemeris(data['RA deg'],  data['DEC deg'], st);
          if (ephemeris.visible) {
              //print(data['NAME']);print("${ephemeris.rising} ${ephemeris.setting} ${ephemeris.culmination}");
              //print("${data['RA']} - ${data['RA deg']}/ ${data['DEC']} - ${data['DEC deg']}");
              data['meridian_time']=ephemeris.culmination;
              data['rise'] = ephemeris.rising;
              data['set']  = ephemeris.setting;
              jsonData.add(data);
              if (data['NAME']=='Sun') {
                sunIsVisible = true;
              }
          }
      }
    }

    ObservableObjects.fromJson(jsonData).catalog;
    return jsonData;
  }
