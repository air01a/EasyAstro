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
  SkyMap(this.lon, this.lat, this.date,
      {this.maxMag = 5.0,
      this.loadDSO = true,
      this.customDSO = const [],
      this.showLines = true});

  @override
  _SkyMap createState() => _SkyMap();
}

class _SkyMap extends State<SkyMap> {
  late SkyMapCreator skyMap;
  bool _ready = false;
  SkyMapPainter? skyMapPainter;
  late double size;

  void callBack() {
    setState(() {
      _ready = true;
      skyMapPainter = SkyMapPainter(
          skyMap.getStarsPosition(),
          skyMap.getConstellations(),
          skyMap.getConstellationLines(),
          skyMap.getDSO(),
          widget.showLines,
          size,
          size);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    size = _min(
        MediaQuery.of(context).size.height, MediaQuery.of(context).size.width);
    skyMap = SkyMapCreator(callBack, 1024, 1024, widget.maxMag, widget.lon,
        widget.lat, widget.date);
    skyMap.loadConfig(widget.loadDSO);
    if (widget.customDSO != []) {
      skyMap.loadDSO(widget.customDSO);
    }
  }

  double _min(double a, double b) {
    if (a < b) return a;
    return b;
  }

  @override
  Widget build(BuildContext context) {
    double newSize = _min(
        MediaQuery.of(context).size.height, MediaQuery.of(context).size.width);
    if (newSize != size) {
      size = newSize;
      skyMapPainter = SkyMapPainter(
          skyMap.getStarsPosition(),
          skyMap.getConstellations(),
          skyMap.getConstellationLines(),
          skyMap.getDSO(),
          widget.showLines,
          size,
          size);
    }
    return Container(
        width: size,
        height: size,
        child: Stack(
          children: [
            Image.asset('assets/astro/horizon.png', width: size, height: size),
            // Dessiner le cercle sur l'image
            if (_ready)
              RepaintBoundary(
                  child: CustomPaint(
                painter: skyMapPainter,
              ))
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

  double width;
  double height;

  bool showLines;

  SkyMapPainter(this.stars, this.constellations, this.lines, this.dsos,
      this.showLines, this.width, this.height);

  void drawPlanet(Canvas canvas, double x, double y, int phase, String title,
      double radius, Color color) {
    final Offset moonCenter = Offset(x * width / 1024, y * height / 1024);
    var paint1 = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    //a circle
    canvas.drawCircle(moonCenter, radius, paint1);
    var paragraph = getText(title, color);
    canvas.drawParagraph(
        paragraph,
        Offset(x * width / 1024 - paragraph.width / 2 + radius / 2 + 3,
            y * height / 1024 + 8));
  }

  ui.Paragraph getText(String text, Color textColor) {
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
      ..layout(ui.ParagraphConstraints(width: width));
    return paragraph;
  }

  void drawDSO(Canvas canvas) {
    for (final dso in dsos) {
      switch (dso.type) {
        case 10:
          {
            drawPlanet(canvas, dso.pos['x'], dso.pos['y'], dso.phase, dso.name,
                4, Colors.red);
          }
          break;
        case 11:
          {
            drawPlanet(canvas, dso.pos['x'], dso.pos['y'], dso.phase, dso.name,
                10, Colors.white);
          }
          break;
        default:
          {
            var paint1 = Paint()
              ..color = Color(dso.color)
              ..style = PaintingStyle.fill;
            //a circle
            canvas.drawCircle(
                Offset(
                    dso.pos['x'] * width / 1024, dso.pos['y'] * height / 1024),
                3,
                paint1);
            var paragraph = getText(dso.name, Color(dso.color));
            canvas.drawParagraph(
                paragraph,
                Offset(dso.pos['x'] * width / 1024 - paragraph.width / 2 + 5,
                    dso.pos['y'] * height / 1024 + 5));
          }
          break;
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      var paint1 = Paint()
        ..color = Color(star.color)
        ..style = PaintingStyle.fill;
      //a circle
      canvas.drawCircle(
          Offset(star.pos['x'] * width / 1024, star.pos['y'] * height / 1024),
          star.radius!,
          paint1);
    }
    if (showLines) {
      for (final constellation in constellations) {
        var paragraph = getText(constellation.name, Colors.cyan);
        canvas.drawParagraph(
            paragraph,
            Offset(constellation.pos['x'] * width / 1024 - paragraph.width / 2,
                constellation.pos['y'] * height / 1024));
      }

      for (final line in lines) {
        final p1 =
            Offset(line[0]['x'] * width / 1024, line[0]['y'] * height / 1024);
        final p2 =
            Offset(line[1]['x'] * width / 1024, line[1]['y'] * height / 1024);

        final paint = Paint()
          ..color = Colors.cyan.shade900
          ..strokeWidth = 1;
        canvas.drawLine(p1, p2, paint);
      }
    }

    drawDSO(canvas);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
