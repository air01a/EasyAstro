import 'package:flutter/material.dart';
import 'package:easyastro/components/pagestructure.dart';
import 'package:easyastro/services/network/protocolHelper.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:easyastro/services/database/globals.dart';
import 'package:easyastro/components/scrollabletextfield.dart';
import 'dart:math';
import 'package:easyastro/components/selectexposition.dart';
import 'package:easyastro/services/telescope/telescopehelper.dart';

class ScreenCapture extends StatefulWidget {
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
  final channel = WebSocketChannel.connect(
      Uri.parse("ws://${ServerInfo().host}/telescope/ws/1234"));

  void moveTelescope(dynamic axis) {
    switch (axis) {
      case 0:
        service.moveTelescope(-1, 0);
        break;
      case 1:
        service.moveTelescope(0, -1);
        break;
      case 2:
        service.moveTelescope(1, 0);
        break;
      case 3:
        service.moveTelescope(0, 1);
        break;
    }
  }

  void fetchImage() async {
    setState(() {
      var rng = Random().nextInt(999999999);
      _imageUrl =
          "http://${ServerInfo().host}/telescope/last_picture?v=$i.$rng";
      i += 1;
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    channel.stream.listen((message) {
      // Mettre à jour l'image en allant la chercher sur l'API
      final info = protocol.analyseMessage(message);
      setState(() {
        _textController.text =
            message + '\n' + _textController.text; // Ajouter une nouvelle ligne
      });
      if (info['refreshImage']) {
        fetchImage();
      }
      if (info['goto_success']) {
        _setStackable(true);
      }
    });
    // Récupérer l'image initiale depuis l'API
    fetchImage();
  }

  void _setStackable(bool stackable) {
    setState(() {
      _isStackable = stackable;
    });
  }

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

  void stack(dynamic object) {
    _setStackable(false);
    service.stackImage(object.toString());
  }

  void selectExposition(dynamic context) {
    expoSelector.showExpositionSelector(context, service.changeExposition);
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null) {
      final Map<String, dynamic> args = arguments as Map<String, String>;
      if (args.containsKey('object')) {
        String newObject = args['object'];
        if (newObject != object) {
          object = args['object'];
          service.changeObject(object);
          _isStackable = false;
        }
      }
    }

    return PageStructure(
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
          Center(child: Text("Object $object")),
          Expanded(
              child: Center(
                  child: Stack(alignment: Alignment.center, children: [
            InteractiveViewer(
              boundaryMargin:
                  const EdgeInsets.all(20.0), // Marge autour de l'image
              minScale: 0.1, // Échelle minimale de zoom
              maxScale: 4.0, // Échelle maximale de zoom
              child: Image.network(
                _imageUrl,
                gaplessPlayback: true,
              ), // Image à afficher
            ),
            Positioned(
              top:
                  0, // Position verticale du bouton par rapport au haut de l'écran
              left:
                  0, // Position horizontale du bouton par rapport à la gauche de l'écran
              child: ElevatedButton(
                  onPressed: () {
                    // Action à effectuer lors du clic sur le bouton
                    setState(() {
                      _isConfigVisible = !_isConfigVisible;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black
                        .withOpacity(0.5), // Couleur semi-transparente
                  ),
                  child: const Opacity(
                      opacity: 0.5, // Opacité de l'icône (0.0 à 1.0)
                      child: Icon(
                        Icons.display_settings,
                      ))),
            ),
            controlButton(_isConfigVisible, Icons.chevron_left, 0, null, null,
                null, moveTelescope, 0),
            controlButton(_isConfigVisible, Icons.expand_less, null, null, null,
                0, moveTelescope, 1),
            controlButton(_isConfigVisible, Icons.navigate_next, null, null, 0,
                null, moveTelescope, 2),
            controlButton(_isConfigVisible, Icons.keyboard_arrow_down, null, 0,
                null, null, moveTelescope, 3),
            controlButton(_isStackable, Icons.library_add, null, 0, 0, null,
                stack, object),
            controlButton(_isConfigVisible, Icons.timer, 0, 0, null, null,
                selectExposition, context),
          ]))),
          Center(
              child: ScrollableTextField(
            controller: _textController,
          ))
        ]));
  }
}
