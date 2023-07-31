import 'package:flutter/material.dart';

class RGBAdjustement extends StatefulWidget {
  RGBAdjustement(
      {super.key,
      required this.size,
      required this.r,
      required this.g,
      required this.b,
      required this.callback});
  final Function(double r, double g, double b) callback;
  double r;
  double g;
  double b;
  final double size;

  @override
  State<RGBAdjustement> createState() => _RGBAdjustement();
}

class _RGBAdjustement extends State<RGBAdjustement> {
  late double r;
  late double g;
  late double b;

  @override
  void initState() {
    super.initState();
    r = widget.r;
    g = widget.g;
    b = widget.b;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        bottom: 10,
        left: 0,
        child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: widget.size,
              padding: const EdgeInsets.all(16.0),
              color: Colors.black.withOpacity(0.8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text("R"),
                      Slider(
                        min: 0,
                        max: 2,
                        label: 'R',
                        value: r,
                        onChangeEnd: (double value) {
                          widget.r = value;
                          setState(() => r = value);
                          widget.callback(value, g, b);
                        },
                        onChanged: (double value) {
                          setState(() => r = value);
                        },
                      )
                    ],
                  ),
                  Row(children: [
                    const Text("G"),
                    Slider(
                      min: 0,
                      max: 2,
                      label: 'G',
                      value: g,
                      onChanged: (double value) {
                        setState(() => g = value);
                      },
                      onChangeEnd: (double value) {
                        widget.g = value;
                        setState(() => g = value);
                        widget.callback(r, value, b);
                      },
                    )
                  ]),
                  Row(children: [
                    const Text("B"),
                    Slider(
                      min: 0,
                      max: 2,
                      label: 'B',
                      value: b,
                      onChangeEnd: (double value) {
                        widget.b = value;
                        setState(() => b = value);
                        widget.callback(r, g, value);
                      },
                      onChanged: (double value) {
                        setState(() => b = value);
                      },
                    )
                  ]),
                ],
              ),
            )));
  }
}

class StretchAdjustement extends StatefulWidget {
  StretchAdjustement(
      {super.key,
      required this.size,
      required this.stretch,
      required this.algo,
      required this.callback});
  final Function(double stretch, int algo) callback;
  double stretch;
  int algo;
  final double size;

  @override
  State<StretchAdjustement> createState() => _StretchAdjustement();
}

class _StretchAdjustement extends State<StretchAdjustement> {
  late double _stretch;

  late double g;
  late double b;
  final List<String> list = <String>['Stretch with clipping', 'MTF Algo'];
  late String _stretchValue;
  @override
  void initState() {
    super.initState();
    _stretch = widget.stretch;
    _stretchValue = list[widget.algo];
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        bottom: 10,
        left: 0,
        child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: widget.size,
              padding: const EdgeInsets.all(16.0),
              color: Colors.black.withOpacity(0.8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text("Stretch"),
                      Slider(
                          label: 'Strech',
                          value: _stretch,
                          onChanged: (double value) {
                            widget.stretch = value;
                            setState(() => _stretch = value);
                          },
                          onChangeEnd: (double value) {
                            widget.stretch = value;
                            setState(() => _stretch = value);
                            widget.callback(value, list.indexOf(_stretchValue));
                          }),
                    ],
                  ),
                  DropdownButton<String>(
                    value: _stretchValue,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    onChanged: (value) {
                      setState(() => _stretchValue = value!);
                      widget.callback(widget.stretch, list.indexOf(value!));
                    },
                    items: list.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  )
                ],
              ),
            )));
  }
}

class LevelAdjustement extends StatefulWidget {
  LevelAdjustement(
      {super.key,
      required this.size,
      required this.white,
      required this.midtones,
      required this.black,
      required this.contrast,
      required this.callback});
  final Function(double r, double g, double b, double contrast) callback;
  double white;
  double midtones;
  double black;
  double contrast;
  double size;

  @override
  State<LevelAdjustement> createState() => _LevelAdjustement();
}

class _LevelAdjustement extends State<LevelAdjustement> {
  late double white;
  late double black;
  late double midtones;
  late double contrast;

  @override
  void initState() {
    super.initState();

    white = widget.white;
    black = widget.black;
    midtones = widget.midtones;
    contrast = widget.contrast;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        bottom: 10,
        left: 0,
        child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: widget.size,
              padding: const EdgeInsets.all(16.0),
              color: Colors.black.withOpacity(0.8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text("White"),
                      Slider(
                        min: 0,
                        max: 255,
                        label: 'White',
                        value: white,
                        onChanged: (double value) {
                          setState(() => white = value);
                        },
                        onChangeEnd: (double value) {
                          widget.white = value;
                          setState(() => white = value);
                          widget.callback(white, midtones, black, contrast);
                        },
                      )
                    ],
                  ),
                  Row(children: [
                    const Text("Midtones"),
                    Slider(
                      min: 0,
                      max: 2,
                      label: 'Midtones',
                      value: midtones,
                      onChanged: (double value) {
                        setState(() => midtones = value);
                      },
                      onChangeEnd: (double value) {
                        widget.midtones = value;
                        setState(() => midtones = value);
                        widget.callback(white, midtones, black, contrast);
                      },
                    )
                  ]),
                  Row(children: [
                    const Text("Black"),
                    Slider(
                      min: 0,
                      max: 255,
                      label: 'Black',
                      value: black,
                      onChanged: (double value) {
                        setState(() => black = value);
                      },
                      onChangeEnd: (double value) {
                        widget.black = value;
                        setState(() => black = value);
                        widget.callback(white, midtones, black, contrast);
                      },
                    )
                  ]),
                  Row(children: [
                    const Text("Contrast"),
                    Slider(
                      min: 0,
                      max: 2,
                      label: 'Contrast',
                      value: contrast,
                      onChanged: (double value) {
                        setState(() => contrast = value);
                      },
                      onChangeEnd: (double value) {
                        widget.contrast = value;
                        setState(() => contrast = value);
                        widget.callback(white, midtones, black, value);
                      },
                    )
                  ]),
                ],
              ),
            )));
  }
}
