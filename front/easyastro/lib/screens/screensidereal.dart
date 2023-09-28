import 'package:easyastro/services/database/globals.dart';
import 'package:easyastro/astro/astrocalc.dart';
import 'package:easyastro/components/structure/pagestructure.dart';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';

class ScreenClock extends StatefulWidget {
  const ScreenClock({super.key});
  @override
  State<ScreenClock> createState() => _ScreenClockState();
}

class _ScreenClockState extends State<ScreenClock> {
  late String currentTime;
  late double currentTS;
  late String currentTSString;
  late DateTime timerInit;
  late AstroCalc astro;
  late Timer timer;
  @override
  void initState() {
    super.initState();
    astro = AstroCalc();
    astro.setPosition(
        CurrentLocation().longitude!, CurrentLocation().latitude!, 0);
    astro.setCurrentTime();
    currentTS = astro.getSiderealTime();
    timerInit = DateTime.now();
    // Init current time
    updateTime();

    // Periodic timer
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateTime();
    });
  }

  void updateTime() {
    if (!mounted) return;
    setState(() {
      double ts = currentTS +
          DateTime.now().difference(timerInit).inSeconds.toDouble() *
              (86400 / 86164.100352) /
              3600;
      currentTSString = ConvertAngle.hourToStringWithSeconds(ts);
      currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageStructure(
        body: Center(
            child: Column(
      children: [
        Text(
          'sidereal_hour'.tr(),
          style: const TextStyle(
            fontSize: 48.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          currentTSString,
          style: const TextStyle(
            fontSize: 48.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(""),
        Text(
          'hour_title'.tr(),
          style: const TextStyle(
            fontSize: 48.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          currentTime,
          style: const TextStyle(
            fontSize: 48.0,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    )));
  }
}
