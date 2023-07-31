import 'dart:convert';

import 'package:easyastro/screens/screenprocessimage.dart';
import 'package:flutter/material.dart';
import 'package:easyastro/services/network/protocolhelper.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:easyastro/services/database/globals.dart';
import 'package:easyastro/components/forms/scrollabletextfield.dart';
import 'dart:math';
import 'package:easyastro/components/forms/selectexposition.dart';
import 'package:easyastro/services/telescope/telescopehelper.dart';
import 'package:easyastro/components/structure/bottombar.dart';
import 'package:easyastro/components/graphics/coloradujstement.dart';
import 'package:easyastro/services/image/processinghelper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:extended_image/extended_image.dart';
import 'package:easyastro/components/loader/loadingindicatordialog.dart';
import 'dart:async';
import 'package:easyastro/models/telescopestatus.dart';
import 'package:easyastro/screens/screenconfigtelescope.dart';
import 'package:easyastro/components/forms/speedgauge.dart';

class ScreenCapture extends StatefulWidget {
  const ScreenCapture({super.key});

  @override
  _ScreenCapture createState() => _ScreenCapture();
}

class _ScreenCapture extends State<ScreenCapture> {
  String _imageUrl = '';
  String object = "";
  int i = 0;

  final protocol = CommunicationProtocol();
  final TextEditingController _textController = TextEditingController();
  final TelescopeHelper service = TelescopeHelper(ServerInfo().host);
  final ExpositionSelector expoSelector = ExpositionSelector();

  bool _isConfigVisible = false;
  bool _isStackable = false;
  bool _imageLoading = false;
  bool _imageToLoad = false;
  bool _isWaiting = false;
  bool _statusVisible = true;
  double _messageHandlerHeight = 10.0;
  double _defaultFontSize = 10.0;
  late WebSocketChannel channel;
  double _speed = 20.0;

  final bbar = BottomBar();
  late RGBAdjustement colorAdjustement;
  late StretchAdjustement stretchAdjustement;
  late LevelAdjustement levelAdjustement;
  ProcessingHelper processingHelper = ProcessingHelper();
  TelescopeStatus? telescopeStatus;

  //#########################################################################################################
  //# API function call to move telescope according to pushed button
  //#########################################################################################################
  void moveTelescope(dynamic axis) {
    switch (axis) {
      case 0:
        service.moveTelescope(-1 * _speed, 0);
        break;
      case 1:
        service.moveTelescope(0, -1 * _speed);
        break;
      case 2:
        service.moveTelescope(1 * _speed, 0);
        break;
      case 3:
        service.moveTelescope(0, 1 * _speed);
        break;
    }
  }

  void changeSpeed(double speed) {
    _speed = speed;
  }

  //#########################################################################################################
  //# Display dialog asking ofr confirmation when changing object
  //#########################################################################################################
  void showConfirmationDialog(String object, String current) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("current_task").tr(args: [current]),
          content: const Text('confirm switch').tr(args: [object]),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Action lorsque l'utilisateur confirme
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
                service.changeObject(object);
                _isStackable = false;
                this.object = object;
              },
              child: const Text('confirm').tr(),
            ),
            TextButton(
              onPressed: () {
                // Action lorsque l'utilisateur annule
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
              child: const Text('cancel').tr(),
            ),
          ],
        );
      },
    );
  }

  //#########################################################################################################
  //# Close WebSocket
  //#########################################################################################################
  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  //#########################################################################################################
  //# init + websocket
  //#########################################################################################################
  @override
  void initState() {
    super.initState();

    bbar.addItem(const Icon(Icons.timer), 'expo-gain'.tr(), selectExposition);
    bbar.addItem(
        const Icon(Icons.zoom_out_map), 'move'.tr(), activateMoveTelescope);
    bbar.addItem(const Icon(Icons.palette), 'modify_image'.tr(), modifyImage);

    bbar.addItem(const Icon(Icons.settings), 'option'.tr(), showOptions);

    channel = WebSocketChannel.connect(
        Uri.parse("ws://${ServerInfo().host}/telescope/ws/1234"));

    channel.stream.listen((message) async {
      print(message);
      // Mettre à jour l'image en allant la chercher sur l'API
      final info = protocol.analyseMessage(jsonDecode(message));

      if (info['displayMessage']) {
        setState(() {
          _textController.text = info['showMessage'] +
              '\n' +
              _textController.text; // Ajouter une nouvelle ligne
        });
      }

      if (info['refreshImage']) {
        reloadImage();
      }

      if (info['imageStacking'] && _isWaiting) {
        _isWaiting = false;
        LoadingIndicatorDialog().dismiss();
      }

      if (info['goto_success']) {
        _setStackable(true);
        telescopeStatus!.currentTask = 'TRACKING';
      }

      if (info['imageStacking'] && (telescopeStatus != null)) {
        telescopeStatus!.stacked = info['stacked'];
        telescopeStatus!.discarded = info['discarded'];
      }
    });
    // Récupérer l'image initiale depuis l'API
    //fetchImage();

    reloadImage();
  }

  //#########################################################################################################
  //# Check if target (object) was send to this page, compare to current object and ask to override if needed
  //#########################################################################################################
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _defaultFontSize = Theme.of(context).textTheme.bodyMedium!.fontSize ?? 20;
    _messageHandlerHeight = _defaultFontSize + 8;

    final arguments = ModalRoute.of(context)?.settings.arguments;
    service.getCurrentObject().then((value) {
      telescopeStatus = value;
      Timer(const Duration(seconds: 4), () {
        _statusVisible = false;
      });
      setState(() {
        _statusVisible = true;
      });
      if (arguments != null) {
        final Map<String, dynamic> args = arguments as Map<String, String>;
        if (args.containsKey('object')) {
          String newObject = args['object'];
          // Get status and if telecope is tracking something
          if (value.currentTask == 'IDLE') {
            service.changeObject(newObject);
            object = newObject;
            _isStackable = false;
          } else {
            if (newObject != value.object) {
              // Ask if user is sure to stop current task
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                showConfirmationDialog(
                    newObject, "${value.currentTask} ${value.object}");
              });
            }
          }
        }
      }
    });
  }

  //#########################################################################################################
  //# Define that goto has succeeded and stack option is available
  //#########################################################################################################
  void _setStackable(bool stackable) {
    setState(() {
      _isStackable = stackable;
    });
  }

  //#########################################################################################################
  //# Go back to plan page
  //#########################################################################################################
  void close(dynamic object) {
    if (ObjectSelection()
        .selection
        .where((line) => line.selected == true)
        .toList()
        .isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/selection');
    } else {
      Navigator.pushReplacementNamed(context, '/plan');
    }
  }

  //#########################################################################################################
  //# route to ScreenProcessingImage page
  //#########################################################################################################
  void modifyImage(dynamic context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScreenProcessingImage(),
      ),
    );
  }

  //#########################################################################################################
  //# Display arrow to move telescope
  //#########################################################################################################
  void _changeMoveState() {
    setState(
      () => _isConfigVisible = !_isConfigVisible,
    );
  }

  //#########################################################################################################
  //# Display message handler
  //#########################################################################################################
  Widget messageHandler() {
    return Positioned(
        left:
            10, // Position horizontale du bouton par rapport à la gauche de l'écran
        top: 0,
        child: Material(
            child: Center(
                child: SizedBox(
                    width: 500,
                    height: _messageHandlerHeight,
                    child: GestureDetector(
                        onTap: () {
                          // Action à exécuter lorsqu'on clique sur le TextField en lecture seule
                          setState(() {
                            if (_messageHandlerHeight ==
                                (_defaultFontSize + 8)) {
                              _messageHandlerHeight = 10 * _defaultFontSize;
                            } else {
                              _messageHandlerHeight = _defaultFontSize + 8;
                            }
                          });
                        },
                        child: AbsorbPointer(
                            absorbing: true,
                            child: ScrollableTextField(
                              controller: _textController,
                            )))))));
  }

  //#########################################################################################################
  //# Display button on top of image
  //#########################################################################################################
  Widget controlButton(
      bool visible,
      IconData? icon,
      double? left,
      double? bottom,
      double? right,
      double? top,
      Function(dynamic)? callback,
      dynamic param) {
    if (visible) {
      return Positioned(
        left:
            left, // Position horizontale du bouton par rapport à la gauche de l'écran
        right: right,
        bottom: bottom,
        top: top,
        child: ElevatedButton(
            onPressed: () {
              // Action à effectuer lors du clic sur le bouton
              if (callback != null) {
                callback(param);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.black.withOpacity(0.5), // Couleur semi-transparente
            ),
            child: Opacity(
                opacity: 0.5, // Opacité de l'icône (0.0 à 1.0)
                child: Icon(icon, size: 48.0))),
      );
    }
    return const SizedBox(width: 0, height: 0);
  }

  //#########################################################################################################
  //# API Call to stack image
  //#########################################################################################################

  void stack(dynamic object) {
    service.stackImage(object.toString());
    _setStackable(false);
    LoadingIndicatorDialog().show(context);
    _isWaiting = true;
  }

  //#########################################################################################################
  //# Change exposition
  //#########################################################################################################
  void selectExposition(dynamic context) {
    expoSelector.showExpositionSelector(context, service.changeExposition);
  }

  //#########################################################################################################
  //# Display Options panel
  //#########################################################################################################

  void showOptions(dynamic context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ConfigTelescopeScreen(),
      ),
    );
  }

  //#########################################################################################################
  //# Force reload image with modification of URL to avoid cache
  //#########################################################################################################
  void reloadImage() async {
    if (!_imageLoading) {
      _imageLoading = true;
      var rng = Random().nextInt(999999999);

      setState(() {
        _imageUrl =
            "http://${ServerInfo().host}/telescope/last_picture?v=$i.$rng";
      });
      i += 1;
    } else {
      _imageToLoad = true;
      Future.delayed(const Duration(milliseconds: 1000), () {
        reloadImage();
      });
    }
  }

  //#########################################################################################################
  //# Display buttons
  //#########################################################################################################

  void activateMoveTelescope(dynamic context) {
    setState(() {
      _isConfigVisible = !_isConfigVisible;
    });
  }

  //#########################################################################################################
  //# Get icons according to download state
  //#########################################################################################################
  Icon getLoadingIcons() {
    if (!_imageLoading) return const Icon(Icons.check_box);
    if (_imageLoading) return const Icon(Icons.restart_alt);
    return const Icon(Icons.check_box);
  }

  //#########################################################################################################
  //# Display status icon about telescope
  //#########################################################################################################
  List<Widget> getStatusIcons() {
    List<Widget> ret = [];
    if (telescopeStatus == null) return ret;
    if (telescopeStatus!.stacking) ret.add(const Icon(Icons.library_add));
    if (telescopeStatus!.currentTask == 'TRACKING') {
      ret.add(const Icon(Icons.location_searching));
      ret.add(Text(telescopeStatus!.object));
    }
    return ret;
  }

  //#########################################################################################################
  //# Main
  //#########################################################################################################
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Scaffold(
            body: Center(
                child: Stack(alignment: Alignment.center, children: [
              SizedBox(
                  // Utiliser un container pour permettre à l'InteractiveViewer de prendre toute la place disponible
                  width: double.infinity,
                  height: double.infinity,
                  child: InteractiveViewer(
                    boundaryMargin: const EdgeInsets.all(
                        double.infinity), // Marge autour de l'image
                    minScale: 0.9, // Échelle minimale de zoom
                    maxScale: 4.0, // Échelle maximale de zoom
                    constrained: true,
                    child:
                        ExtendedImage.network(_imageUrl, gaplessPlayback: true,
                            loadStateChanged: (ExtendedImageState state) {
                      switch (state.extendedImageLoadState) {
                        case LoadState.loading:
                          break;
                        case LoadState.completed:
                          _imageLoading = false;
                          break;
                        case LoadState.failed:
                          _imageLoading = false;
                          break;
                      }
                      return null;
                    }),
                  )),
              controlButton(_isConfigVisible, Icons.chevron_left, 0, null, null,
                  null, moveTelescope, 0),
              controlButton(_isConfigVisible, Icons.expand_less, null, null,
                  null, 0, moveTelescope, 1),
              controlButton(_isConfigVisible, Icons.navigate_next, null, null,
                  0, null, moveTelescope, 2),
              controlButton(_isConfigVisible, Icons.keyboard_arrow_down, null,
                  0, null, null, moveTelescope, 3),
              controlButton(_isStackable, Icons.library_add, null, 0, 0, null,
                  stack, object),
              Positioned(right: 0, bottom: 0, child: getLoadingIcons()),
              if (_isConfigVisible)
                Positioned(
                    bottom: 100,
                    right: 0,
                    child: SpeedGauge(
                        initialValue: _speed, onValueChanged: changeSpeed)),
              Positioned(
                  left: 0, bottom: 0, child: Row(children: getStatusIcons())),
              controlButton(true, Icons.close, null, null, 0, 0, close, 0),
              messageHandler(),
              if (telescopeStatus != null)
                Visibility(
                  visible: _statusVisible,
                  child: Positioned(
                    child: Container(
                      width: 200,
                      height: 100,
                      color: Colors.grey,
                      child: Center(
                          child: Column(children: [
                        Text(
                          telescopeStatus?.currentTask ?? 'Initializing',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                        Text("Object: ${telescopeStatus?.object ?? ''}"),
                        Text("RA: ${telescopeStatus?.ra ?? ''}"),
                        Text("DEC: ${telescopeStatus?.dec ?? ''}"),
                      ])),
                    ),
                  ),
                ),
            ])),
            bottomNavigationBar: bbar));
  }
}
