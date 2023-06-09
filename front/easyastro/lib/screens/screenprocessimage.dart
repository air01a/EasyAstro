import 'package:flutter/material.dart';
import 'package:easyastro/services/database/globals.dart';
import 'package:easyastro/components/selectexposition.dart';
import 'package:easyastro/services/telescope/telescopehelper.dart';
import 'package:easyastro/components/bottombar.dart'; 
import 'package:easyastro/components/coloradujstement.dart';
import 'dart:typed_data';
import 'package:easyastro/services/image/imagehelper.dart';
import 'package:easyastro/services/image/processingHelper.dart';
import 'package:easyastro/components/pagestructure.dart';
import 'package:fl_chart/fl_chart.dart';

class ScreenProcessingImage extends StatefulWidget {
  @override
  _ScreenProcessingImage createState() => _ScreenProcessingImage();
}

class _ScreenProcessingImage extends State<ScreenProcessingImage> {
  int i=0;

  ProcessingHelper processingHelper = ProcessingHelper();
  final TelescopeHelper service = TelescopeHelper(ServerInfo().host);
  final ExpositionSelector expoSelector = ExpositionSelector();

  bool _isConfigVisible = false;
  bool _rgbVisible = false;
  bool _levelsVisible = false;
  bool _stretchVisible = false; 

  final bbar = BottomBar();
  late RGBAdjustement colorAdjustement ;
  late StretchAdjustement stretchAdjustement;
  late LevelAdjustement levelAdjustement;


  late ByteData imageData;
  Uint8List? encodedImage;

  late ImageHelper imageHelper;

  @override
  void initState() {
    super.initState();
    imageHelper = ImageHelper(reloadImage);
    colorAdjustement = RGBAdjustement(size:400,r:imageHelper.r,g:imageHelper.g,b:imageHelper.b,callback:changeRGB);
    stretchAdjustement = StretchAdjustement(size:400, stretch: imageHelper.stretch, callback:changeStretch);
    levelAdjustement = LevelAdjustement(size:400, white:imageHelper.white, midtones:imageHelper.midtones, black:imageHelper.black,contrast:imageHelper.contrast, callback:changeLevel);
    bbar.addItem(const Icon(Icons.palette ), 'RGB Balance', _viewRGB);
    bbar.addItem(const Icon(Icons.contrast), 'Levels', _viewLevels);
    bbar.addItem(const Icon(Icons.sync_alt ), 'Stretch', _viewStretch);
    imageHelper.getParameters();
    imageHelper.downloadImage();
  }

  void close(dynamic object) {
    Navigator.pushReplacementNamed(context, '/home');
  }
  void _changeMoveState() {
    setState(() => _isConfigVisible = ! _isConfigVisible,);
  }

  void changeProcessing() async {
    processingHelper.changeProcessingParameters(imageHelper.black.toInt(), imageHelper.white.toInt(), imageHelper.midtones, imageHelper.stretch, imageHelper.r, imageHelper.g, imageHelper.b, imageHelper.contrast);
  }

  void changeRGB(double r, double g, double b) {
    imageHelper.r = r;
    imageHelper.g = g;
    imageHelper.b = b;
    changeProcessing();
    reloadImage();
  }

  void reloadImage() {
    setState(() => imageHelper.generateEncoded());
  }

  void changeLevel(double white, double midtones, double black, double contrast) {
    imageHelper.white = white;
    imageHelper.black = black;
    imageHelper.midtones = midtones;
    imageHelper.contrast = contrast;
    changeProcessing();
    reloadImage();
  }


  void changeStretch(double stretch) async {
    imageHelper.stretch = stretch;
    changeProcessing();
    imageHelper.downloadImage();
  }

  void _viewRGB(BuildContext context) async {
    colorAdjustement = RGBAdjustement(size:400,r:imageHelper.r,g:imageHelper.g,b:imageHelper.b,callback:changeRGB);
    
    setState(() {
       _rgbVisible = ! _rgbVisible;
       _levelsVisible = false; 
       _stretchVisible = false;
    });
  }

  void _viewLevels(BuildContext context) {
    levelAdjustement = LevelAdjustement(size:400, white:imageHelper.white, midtones:imageHelper.midtones, black:imageHelper.black,contrast:imageHelper.contrast, callback:changeLevel);

    setState(() {
      _levelsVisible = ! _levelsVisible;
      _stretchVisible = false;
      _rgbVisible = false;
    });

  }

  void _viewStretch(BuildContext context) {
    stretchAdjustement = StretchAdjustement(size:400, stretch: imageHelper.stretch, callback:changeStretch);

    setState(() {
      _stretchVisible = ! _stretchVisible;
      _rgbVisible = false;
      _levelsVisible = false; 
    });
}


  Widget getHistogram() {
      final histo = imageHelper.getHistogram();
      List<BarChartGroupData> redBarChartGroups = List.generate(
        256,
        (index) => BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: histo['red']![index].toDouble(),
              color: Colors.red,
              width: 8,
            ),
          ],
        ),
      );

      List<BarChartGroupData> greenBarChartGroups = List.generate(
        256,
        (index) => BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY:  histo['green']![index].toDouble(),
              color: Colors.green,
              width: 8,
            ),
          ],
        ),
      );

        List<BarChartGroupData> blueBarChartGroups = List.generate(
          256,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY:  histo['blue']![index].toDouble(),
                color: Colors.blue,
                width: 8,
              ),
              BarChartRodData(
              toY:  histo['green']![index].toDouble(),
              color: Colors.green,
              width: 8,
            ),BarChartRodData(
              toY: histo['red']![index].toDouble(),
              color: Colors.red,
              width: 8,
            ),
          
            ],
          ),
        );


        return BarChart(
          BarChartData(
            groupsSpace: 8,
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: blueBarChartGroups,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return PageStructure(body: Center(child: Scaffold(body: Stack(
                              alignment: Alignment.center,
                              children: [
                                    if (imageHelper.encoded!=null)
                                    InteractiveViewer(
                                        boundaryMargin: const EdgeInsets.all(20.0), // Marge autour de l'image
                                        minScale: 0.1, // Échelle minimale de zoom
                                        maxScale: 4.0, // Échelle maximale de zoom
                                        child: Image.memory(imageHelper.encoded!, gaplessPlayback: true,), // Image à afficher
                                  ),

                                  if (_rgbVisible) colorAdjustement,
                                  if (_stretchVisible) stretchAdjustement,
                                  if (_levelsVisible) levelAdjustement,
                                   //Positioned(top:0, right:0,child: Container(width:300,height:100,child:getHistogram())),
                                    ]),
                          bottomNavigationBar: bbar)), showDrawer: false, title:"Image processing");
                  
  }
} 