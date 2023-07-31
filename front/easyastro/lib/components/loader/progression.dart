import 'package:flutter/material.dart';
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';


class ProgressIndicator extends StatefulWidget {
  final  Future<dynamic> Function()  controller ;
  const ProgressIndicator(this.controller, {super.key} );

  @override
  State<ProgressIndicator> createState() =>
      _ProgressIndicatorState();
}

class _ProgressIndicatorState extends State<ProgressIndicator>
    with TickerProviderStateMixin {
  double value = 0;
  Timer? timer;
  bool _finished = false;


  void startData (){
     timer = Timer.periodic(
         const Duration(seconds: 1),
             (Timer timer) async {
            value = await widget.controller()/100;
            setState(() {
              if(value >= 1) {
                  timer.cancel();
                  _finished=true;
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
            if (_finished)
            ElevatedButton(onPressed:  () { Navigator.of(context).pop(); }, child: Text('ok'.tr()))
          ],
        ),
      ),
    );
  }
}


class LoadingIndicator extends StatelessWidget{
  const LoadingIndicator({super.key, this.text = '', required this.controller});

  final String text;
  final Future<dynamic> Function() controller;

  @override
  Widget build(BuildContext context) {
    var displayedText = text;

    return Container(
        padding: const EdgeInsets.all(16),
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
        padding: const EdgeInsets.only(bottom: 16),
        child: SizedBox(width:200,height:200, child:ProgressIndicator(controller))
    );
  }

  Widget _getHeading(context, text) {
    return
      Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16
            ),
            textAlign: TextAlign.center,
          )
      );
  }

}