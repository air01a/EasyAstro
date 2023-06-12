import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:easyastro/astro/astrocalc.dart';
import 'package:easyastro/services/globals.dart';

class AzimutalGraph extends StatefulWidget {
  final Map<double,double> data; 
  const AzimutalGraph({super.key,required this.data});


  @override
  State<AzimutalGraph> createState() => _AzimutalGraph();
}

class _AzimutalGraph extends State<AzimutalGraph> {
  List<Color> gradientColors = [
    const Color(0xFF50E4FF),
    const Color(0xFF2196F3),
  ];

  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            child: LineChart(
              showAvg ? avgData() : mainData(),
            ),
          ),
        ),
        SizedBox(
          width: 60,
          height: 15  ,
          child: TextButton(
            onPressed: () {
              setState(() {
                showAvg = !showAvg;
              });
            },
            child: Text(
              'Height',
              style: TextStyle(
                fontSize: 12,
                color: showAvg ? Colors.white.withOpacity(0.5) : Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {

    Widget text;
    const style = TextStyle(
      fontSize: 10,
    );
    text = Text(ConvertAngle.hourToString(value), style: style);
    
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    String text;
    text = (value.toString());

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {

    List<FlSpot> tab=[];
    double minX=1000;
    double maxX=0;
    widget.data.forEach((i, value) {
      tab.add(FlSpot(i,value.floor()+0.0));
      if (i<minX) minX=i;
      if (i>maxX) maxX=i;
    });
    
    return LineChartData(
      lineTouchData: LineTouchData(
    enabled: true,
    touchCallback:
        (FlTouchEvent event, LineTouchResponse? touchResponse) {
      // TODO : Utilize touch event here to perform any operation
    },
    touchTooltipData: LineTouchTooltipData(
      tooltipBgColor: Colors.blue,
      tooltipRoundedRadius: 20.0,
      showOnTopOfTheChartBoxArea: true,
      fitInsideHorizontally: true,
      tooltipMargin: 0,
      getTooltipItems: (touchedSpots) {
        return touchedSpots.map(
          (LineBarSpot touchedSpot) {
            const textStyle = TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            );
            return LineTooltipItem(
              "${ConvertAngle.hourToString(tab[touchedSpot.spotIndex].x)} : ${tab[touchedSpot.spotIndex].y.toStringAsFixed(2)}°",
              textStyle,
            );
          },
        ).toList();
      },
    ),
    getTouchedSpotIndicator:
        (LineChartBarData barData, List<int> indicators) {
      return indicators.map(
        (int index) {
          final line = FlLine(
              color: Colors.grey,
              strokeWidth: 1,
              dashArray: [2, 4]);
          return TouchedSpotIndicatorData(
            line,
            FlDotData(show: false),
          );
        },
      ).toList();
    },
    getTouchLineEnd: (_, __) => double.infinity
  ),
      rangeAnnotations: RangeAnnotations(
        verticalRangeAnnotations: [
          VerticalRangeAnnotation(
            x1: ObjectSelection().astro!.hour,
            x2: ObjectSelection().astro!.hour+1,
            color: const Color(0xFF2196F3).withOpacity(0.2),
          )]),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        drawHorizontalLine: true,
        horizontalInterval: 30,
        verticalInterval: 15,
        getDrawingHorizontalLine: (value) {
          if (value == 0) {
              // Style de la ligne y = 0
              return FlLine(
                color: Colors.red,
                strokeWidth: 2.0,
              );
          }


          return  FlLine(
            color: Colors.white10,
            strokeWidth: 0.1,
          );
        },
        getDrawingVerticalLine: (value) {
          return  FlLine(
            color: Colors.white10,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles:  AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles:  AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 5,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 30,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: minX,
      maxX: maxX,
      minY: -90,
      maxY: 90,
      lineBarsData: [
        LineChartBarData(
          spots: tab,
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData:  FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    return LineChartData(
      lineTouchData:  LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return  FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return  FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
            interval: 1,
          ),
        ),
        topTitles:  AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles:  AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3.44),
            FlSpot(2.6, 3.44),
            FlSpot(4.9, 3.44),
            FlSpot(6.8, 3.44),
            FlSpot(8, 3.44),
            FlSpot(9.5, 3.44),
            FlSpot(11, 3.44),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData:  FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }
}