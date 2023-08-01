import 'package:flutter/material.dart';
import 'package:easyastro/services/skymapdraw.dart';
import 'package:easyastro/models/stars.dart';
import 'package:easyastro/models/constellations.dart';
import 'package:easyastro/models/dso.dart';
import 'dart:ui' as ui;

class SkyMap extends StatefulWidget {
  double lon;
  double lat;
  DateTime date;
  double maxMag;
  bool loadDSO;
  bool showLines;
  List<DSO> customDSO;
  double size;

  Function(double magnitude)? setMaxMagnitudeHandler;
  Function()? reloadHandler;
  Function(bool)? showConstellationHandler;
  Function()? reloadDSOHandler;

  SkyMap(this.lon, this.lat, this.date,
      {this.maxMag = 5.0,
      this.loadDSO = true,
      this.customDSO = const [],
      this.showLines = true,
      this.size = 1400});

  void setMaxMagnitude(double magnitude) {
    if (setMaxMagnitudeHandler != null) setMaxMagnitudeHandler!(magnitude);
  }

  void reload() {
    if (reloadHandler != null) reloadHandler!();
  }

  void showConstellation(bool show) {
    if (showConstellationHandler != null) {
      showConstellationHandler!(show);
      showLines = !showLines;
    }
  }

  void reloadDSO(List<DSO> dso) {
    if (reloadDSOHandler != null) {
      this.customDSO = dso;
      reloadDSOHandler!();
    }
  }

  @override
  _SkyMap createState() => _SkyMap();
}

class _SkyMap extends State<SkyMap> {
  late SkyMapCreator skyMap;
  bool _ready = false;
  SkyMapPainter? skyMapPainter;
  late double size;
  bool _init = false;

  final _counter = ValueNotifier<int>(0);

  void callBack() {
    setState(() {
      _ready = true;
      skyMapPainter = SkyMapPainter(
          _counter,
          skyMap.getStarsPosition(),
          skyMap.getConstellations(),
          skyMap.getConstellationLines(),
          skyMap.getDSO(),
          widget.showLines);
    });
  }

  @override
  void initState() {
    super.initState();
    widget.setMaxMagnitudeHandler = changeMagnitude;
    widget.reloadHandler = reload;
    widget.showConstellationHandler = showConstellation;
    widget.reloadDSOHandler = reloadDSO;
  }

  void showConstellation(bool show) {
    skyMapPainter!.showLines = show;
  }

  void reload() {
    _counter.value++;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      _init = true;
      size = widget.size;
      skyMap = SkyMapCreator(
          callBack, widget.maxMag, widget.lon, widget.lat, widget.date);
      reloadDSO();
    }
  }

  void reloadDSO() {
    skyMap.loadConfig(widget.loadDSO);
    print("reload dso");
    if (widget.customDSO != []) {
      print("reload custim ");
      skyMap.loadDSO(widget.customDSO);
    }
    _counter.value++;
  }

  double _min(double a, double b) {
    if (a < b) return a;
    return b;
  }

  void changeMagnitude(double magnitude) {
    skyMap.changeMaxMag(magnitude);
    skyMap.reloadStars();
    _counter.value++;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: size,
        height: size,
        child: Stack(
          children: [
            Image.asset('assets/astro/horizon.png', width: size, height: size),
            if (_ready)
              RepaintBoundary(
                  child: Container(
                      width: size,
                      height: size,
                      child: CustomPaint(
                        painter: skyMapPainter,
                      )))
            else
              Center(child: const CircularProgressIndicator()),
            // Charger l'image depuis les assets
          ],
        ));
  }
}

class SkyMapPainter extends CustomPainter {
  List<Star> stars;
  List<Constellation> constellations;
  List<List<Map<String, dynamic>>> lines;
  List<DSO> dsos;

  bool showLines;

  ValueNotifier<int> notifier;

  SkyMapPainter(this.notifier, this.stars, this.constellations, this.lines,
      this.dsos, this.showLines)
      : super(repaint: notifier);

  void drawPlanet(Canvas canvas, Size size, double x, double y, int phase,
      String title, double radius, Color color) {
    final Offset moonCenter = Offset(x * size.width, y * size.height);
    var paint1 = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    //a circle
    canvas.drawCircle(moonCenter, radius, paint1);
    var paragraph = getText(size, title, color);
    canvas.drawParagraph(
        paragraph,
        Offset(x * size.width - paragraph.width / 2 + radius / 2 + 3,
            y * size.height + 8));
  }

  ui.Paragraph getText(Size size, String text, Color textColor) {
    final double fontSize = 10.0;
    final ui.TextStyle textStyle = ui.TextStyle(
      color: textColor,
      fontFamily: 'Arial',
      fontSize: fontSize,
    );

    final ui.ParagraphBuilder paragraphBuilder =
        ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: TextAlign.center,
      fontSize: fontSize,
    ))
          ..pushStyle(textStyle)
          ..addText(text);

    final ui.Paragraph paragraph = paragraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: size.width));
    return paragraph;
  }

  void drawDSO(Canvas canvas, Size size) {
    for (final dso in dsos) {
      switch (dso.type) {
        case 10:
          {
            drawPlanet(canvas, size, dso.pos['x'], dso.pos['y'], dso.phase,
                dso.name, 4, Colors.red);
          }
          break;
        case 11:
          {
            drawPlanet(canvas, size, dso.pos['x'], dso.pos['y'], dso.phase,
                dso.name, 10, Colors.white);
          }
          break;
        default:
          {
            var paint1 = Paint()
              ..color = Color(dso.color)
              ..style = PaintingStyle.fill;
            //a circle
            canvas.drawCircle(
                Offset(dso.pos['x'] * size.width, dso.pos['y'] * size.height),
                3,
                paint1);
            var paragraph = getText(size, dso.name, Color(dso.color));
            canvas.drawParagraph(
                paragraph,
                Offset(dso.pos['x'] * size.width - paragraph.width / 2 + 5,
                    dso.pos['y'] * size.height + 5));
          }
          break;
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    print(size);
    for (final star in stars) {
      var paint1 = Paint()
        ..color = Color(star.color)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
          Offset(star.pos['x'] * size.width, star.pos['y'] * size.height),
          star.radius!,
          paint1);
    }
    if (showLines) {
      for (final constellation in constellations) {
        var paragraph = getText(size, constellation.name, Colors.cyan);
        canvas.drawParagraph(
            paragraph,
            Offset(constellation.pos['x'] * size.width - paragraph.width / 2,
                constellation.pos['y'] * size.height));
      }

      for (final line in lines) {
        final p1 =
            Offset(line[0]['x'] * size.width, line[0]['y'] * size.height);
        final p2 =
            Offset(line[1]['x'] * size.width, line[1]['y'] * size.height);

        final paint = Paint()
          ..color = Colors.cyan.shade900
          ..strokeWidth = 1;
        canvas.drawLine(p1, p2, paint);
      }
    }

    drawDSO(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
