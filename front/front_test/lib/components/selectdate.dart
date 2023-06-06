import 'package:flutter/material.dart';
import 'package:front_test/services/servicecheck.dart';
import 'package:intl/intl.dart';

class SelectDate {
static final ServiceCheckHelper _checkHelper = ServiceCheckHelper();

static Future<Map<String,dynamic>> selectDate(BuildContext context, DateTime currentDate, TimeOfDay currentTime) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:currentDate,
      firstDate: DateTime(2000),//.now(),
      lastDate: DateTime(2101),
    );


    if (picked==null)
      return {'nopickup': true};

    final TimeOfDay? picked2 = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );

    if (picked2 != null) {
   
        String hour = picked2.hour.toString();if (hour.length==1)  hour = "0$hour";
        String min  = picked2.minute.toString();if (min.length==1) min = "0$min";
        

        String newDate = "${DateFormat("yyyy-MM-dd").format(picked)} $hour:$min";
        print (newDate);
        await _checkHelper.updateTime(newDate);


        return {'nopickup':false, 'date':picked, 'time':picked2, 'str':newDate};

    }
    return  {'nopickup': true};
  }
}