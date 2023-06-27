import 'package:easyastro/screens/screenprocessimage.dart';
import 'package:flutter/material.dart';
import 'package:easyastro/services/network/protocolHelper.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:easyastro/services/database/globals.dart';
import 'package:easyastro/components/scrollabletextfield.dart';
import 'dart:math';
import 'package:easyastro/components/selectexposition.dart';
import 'package:easyastro/services/telescope/telescopehelper.dart';
import 'package:easyastro/components/bottombar.dart'; 
import 'package:easyastro/components/coloradujstement.dart';
import 'package:easyastro/services/image/processingHelper.dart';
import 'package:easy_localization/easy_localization.dart';


class ScreenCapture extends StatefulWidget {
  @override
  _ScreenCapture createState() => _ScreenCapture();
}

class _ScreenCapture extends State<ScreenCapture> {

  String _imageUrl='';
  String object ="";
  int i=0;

  final protocol = CommunicationProtocol();
  final TextEditingController _textController = TextEditingController();
  final TelescopeHelper service = TelescopeHelper(ServerInfo().host);
  final ExpositionSelector expoSelector = ExpositionSelector();

  bool _isConfigVisible = false;
  bool _isStackable = false;

  final channel = WebSocketChannel.connect(Uri.parse("ws://${ServerInfo().host}/telescope/ws/1234"));


  final bbar = BottomBar();
  late RGBAdjustement colorAdjustement ;
  late StretchAdjustement stretchAdjustement;
  late LevelAdjustement levelAdjustement;
  ProcessingHelper processingHelper = ProcessingHelper();

  void moveTelescope(dynamic axis) {
    switch(axis) {
      case 0: service.moveTelescope(-1, 0);
              break;
      case 1: service.moveTelescope(0,-1);
              break;
      case 2: service.moveTelescope(1,0);
              break;
      case 3: service.moveTelescope(0,1);
              break;
    }
  }

  void showConfirmationDialog(String object, String current)  {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("current_task").tr(args: [current]),
          content: Text('confirm switch').tr(args:[object]),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Action lorsque l'utilisateur confirme
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
                service.changeObject(object);
                _isStackable = false;
              },
              child: Text('confirm').tr(),
            ),
            TextButton(
              onPressed: () {
                // Action lorsque l'utilisateur annule
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
              child: Text('cancel').tr(),
            ),
          ],
        );
      },
    );
}

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    bbar.addItem(const Icon(Icons.timer),'expo-gain'.tr(),selectExposition);
    bbar.addItem(const Icon(Icons.zoom_out_map),'move'.tr(),activateMoveTelescope);
    bbar.addItem(const Icon(Icons.palette ), 'modify_image'.tr(), modifyImage);

     
    channel.stream.listen((message) async {
      // Mettre à jour l'image en allant la chercher sur l'API
      final info = protocol.analyseMessage(message);
      setState(() {
          _textController.text = message + '\n' + _textController.text; // Ajouter une nouvelle ligne
      });
      if (info['refreshImage']) {
        reloadImage();
      }
      if (info['goto_success']) {
        _setStackable(true);
      }
      
    });
    // Récupérer l'image initiale depuis l'API
    //fetchImage();
    
   
    reloadImage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null) {
      final Map<String,dynamic> args = arguments as Map<String, String> ;
      if (args.containsKey('object')) {

        String newObject = args['object'];
        service.getCurrentObject().then((value) {
          if (value == 'IDLE')
          {
            service.changeObject(newObject);
            _isStackable = false;
          } else {
            if (newObject != value) {
                  WidgetsBinding.instance?.addPostFrameCallback((_) async {
                      showConfirmationDialog(newObject, value);
                  });           

            }
          }
        },);
        
      }
    }
}

  void _setStackable(bool stackable) {
    setState(() {
      _isStackable = stackable;
    });

  }

  void close(dynamic object) {
    Navigator.pushReplacementNamed(context, '/home');
  }

  void modifyImage(dynamic context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScreenProcessingImage(),
      ),
    );
  }

  void _changeMoveState() {
    setState(() => _isConfigVisible = ! _isConfigVisible,)
    ;
  }

  Widget controlButton(bool visible, IconData? icon, double ?left, double ?bottom, double ?right, double ?top, Function(dynamic) ?callback, dynamic param) {
    if (visible) {
        return Positioned(
        
        left: left, // Position horizontale du bouton par rapport à la gauche de l'écran
        right : right,
        bottom : bottom,
        top : top,
        child: ElevatedButton(
          onPressed: () {
            // Action à effectuer lors du clic sur le bouton
            if (callback!=null) {
              callback(param);
            }
          },
          style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.5), // Couleur semi-transparente
          ),
          child: Opacity(
                opacity: 0.5, // Opacité de l'icône (0.0 à 1.0)
                child: Icon(
                                icon,
                                size: 48.0
                )
          )
        ),
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

  void reloadImage() {
    var rng = Random().nextInt(999999999);
    setState(() {
      _imageUrl = "http://${ServerInfo().host}/telescope/last_picture?v=$i.$rng";

    });
    i+=1;
  }




  void activateMoveTelescope(dynamic context) {
    
    setState(() {
      _isConfigVisible = !_isConfigVisible;
    });
  }

  

  @override
  Widget build(BuildContext context) {

    
    return Center(child: Scaffold(body: Stack(
                              alignment: Alignment.center,
                              children: [
                                    InteractiveViewer(
                                        boundaryMargin: const EdgeInsets.all(20.0), // Marge autour de l'image
                                        minScale: 0.1, // Échelle minimale de zoom
                                        maxScale: 4.0, // Échelle maximale de zoom
                                        child: Image.network(_imageUrl, gaplessPlayback: true,), // Image à afficher
                                  ),

                                  controlButton(_isConfigVisible,Icons.chevron_left, 0, null, null, null, moveTelescope,0),
                                  controlButton(_isConfigVisible,Icons.expand_less, null, null, null, 0, moveTelescope,1),
                                  controlButton(_isConfigVisible,Icons.navigate_next, null, null, 0, null, moveTelescope,2),
                                  controlButton(_isConfigVisible,Icons.keyboard_arrow_down, null, 0, null, null, moveTelescope,3),
                                  controlButton(_isStackable,Icons.library_add, null, 0, 0, null, stack, object),

                                  controlButton(true,Icons.close, null, null, 0, 0, close,0),
                                    Positioned(
                                          left: 10, // Position horizontale du bouton par rapport à la gauche de l'écran
                                          top : 0,
                                          child:Material(child:Center(child: SizedBox(width: 400,height:30,child:ScrollableTextField(
                                                                            controller: _textController,
                                                                      )))
                                    )
                              )]),
                          bottomNavigationBar: bbar));
                  
  }
/*
  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null) {
      final Map<String,dynamic> args = arguments as Map<String, String> ;
      if (args.containsKey('object')) {
        String newObject = args['object'];
        if (newObject!=object) {
          object = args['object'] ;
          service.changeObject(object);
          _isStackable = false;
        }
      }
    }
    return mobilePage();

  }*/
} 