import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SpeedGauge extends StatefulWidget {
  final double initialValue;
  final Function(double) onValueChanged;
  const SpeedGauge(
      {super.key, required this.initialValue, required this.onValueChanged});

  @override
  State<SpeedGauge> createState() => _SpeedGauge();
}

class _SpeedGauge extends State<SpeedGauge> {
  late double _pointerValue;

  @override
  void initState() {
    super.initState();
    _pointerValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      height: 200,
      width: 200,
      child: SfLinearGauge(
        orientation: LinearGaugeOrientation.vertical,
        markerPointers: [
          LinearShapePointer(
            value: _pointerValue,
            height: 25,
            width: 25,
            shapeType: LinearShapePointerType.invertedTriangle,
            dragBehavior: LinearMarkerDragBehavior.free,
            onChanged: (double newValue) {
              setState(() {
                _pointerValue = newValue;
              });
              widget.onValueChanged(newValue);
            },
          ),
        ],
        barPointers: [LinearBarPointer(value: _pointerValue)],
      ),
    );
  }
}
