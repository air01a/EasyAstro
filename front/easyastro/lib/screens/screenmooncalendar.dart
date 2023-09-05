import 'package:flutter/material.dart';
import 'package:easyastro/components/structure/pagestructure.dart';
import 'package:easyastro/services/database/globals.dart';
import 'package:easyastro/astro/astrocalc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easyastro/services/skymap/displaysolarsystemhelper.dart';
import 'package:sweph/sweph.dart';

class ScreenMoonCalendar extends StatelessWidget {
  AstroCalc? astro = ObjectSelection().astro;
  DisplaySolarSystemHelper solarSystemHelper = DisplaySolarSystemHelper();

  @override
  Widget build(BuildContext context) {
    DateTime pDate = DateTime.now();

    //int currentDayOfWeek = now.weekday;
    final days = "days".tr().split(";");
    List<Widget> calendar = [];

    List<int> moonPhase =
        astro!.getMoonPhaseForDate(pDate.year, pDate.month, pDate.day, 20);
    int phase = moonPhase[1];
    for (int i = 0; i < 29; i++) {
      int day = pDate.weekday;

      String formattedDate = DateFormat('MM/dd'.tr()).format(pDate);
      if (days.length == 7) {
        formattedDate = "$formattedDate\n${days[day - 1]}";
      }
      calendar.add(Container(
          width: 80,
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(
                color: Colors.grey), // Définir la couleur de la bordure
          ),
          child: Column(children: [
            Text(
              formattedDate,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            SizedBox(
                width: 80,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: solarSystemHelper.getMoonImage(phase),
                ))
          ])));
      pDate = pDate.add(const Duration(days: 1));
      phase = (phase + 1) % 30;
    }

    return PageStructure(
        body: SingleChildScrollView(
            child: IntrinsicHeight(
                child: SizedBox(
                    width: double.infinity,
                    child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        direction: Axis.horizontal,
                        spacing: 0,
                        children: calendar)))),

        /*GridView.count(
            primary: true,
            padding: const EdgeInsets.all(5),
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
            crossAxisCount: 4,
            children: calendar),*/
        showDrawer: false,
        title: "moon_calendar".tr());
  }
}
