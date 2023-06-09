import 'package:flutter/material.dart';
import 'dart:async';

class ProgressIndicator extends StatefulWidget {
  final  Future<dynamic> Function()  controller ;
  const ProgressIndicator(this.controller );

  @override
  State<ProgressIndicator> createState() =>
      _ProgressIndicatorState();
}

class _ProgressIndicatorState extends State<ProgressIndicator>
    with TickerProviderStateMixin {
  double value = 0;
  Timer? timer;

  void startData (){
     timer = Timer.periodic(
         const Duration(seconds: 1),
             (Timer timer) async {
            value = await widget.controller()/100;
            setState(() {
              if(value >= 1) {
                  timer.cancel();
              }
              else {
                  value = value;
              }
            });
         }
     );
  }


  @override
  void initState() {
    
    super.initState();
    startData();
  }

  @override
  void dispose() {
    if (timer!=null) {
      timer?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            LinearProgressIndicator(
              value: value,
              semanticsLabel: 'Linear progress indicator',
            ),
          ],
        ),
      ),
    );
  }
}


class LoadingIndicator extends StatelessWidget{
  LoadingIndicator({this.text = '', required this.controller});

  final String text;
  final Future<dynamic> Function() controller;

  @override
  Widget build(BuildContext context) {
    var displayedText = text;

    return Container(
        padding: EdgeInsets.all(16),
        color: Colors.black87,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _getLoadingIndicator(),
              _getHeading(context, displayedText)
            ]
        )
    );
  }

  Padding _getLoadingIndicator() {
    return Padding(
        child: Container(width:200,height:200, child:ProgressIndicator(controller)),
        padding: EdgeInsets.only(bottom: 16)
    );
  }

  Widget _getHeading(context, text) {
    return
      Padding(
          child: Text(
            text,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16
            ),
            textAlign: TextAlign.center,
          ),
          padding: EdgeInsets.only(bottom: 4)
      );
  }

}