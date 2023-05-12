import 'package:flutter/material.dart';
import 'package:front_test/components/pagestructure.dart';
import 'package:front_test/services/protocol.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:front_test/services/globals.dart';
import 'package:front_test/services/servicecheck.dart';
import 'package:front_test/components/scrollabletextfield.dart';
import 'dart:math';

class ScreenCapture extends StatefulWidget {
  @override
  _ScreenCapture createState() => _ScreenCapture();
}

class _ScreenCapture extends State<ScreenCapture> {
  String _imageUrl = '';
  String object ="";
  int i=0;
  final protocol = CommunicationProtocol();
  final TextEditingController _textController = TextEditingController();
  final ServiceCheckHelper service = ServiceCheckHelper();
  bool _isConfigVisible = false;
  bool _isStackable = false;
  final channel = WebSocketChannel .connect(Uri.parse("ws://${ServerInfo().host}/telescope/ws/1234"));

  void fetchImage() async {
    setState(() {
      var rng = Random().nextInt(999999999);
      _imageUrl = "http://${ServerInfo().host}/telescope/last_picture?v=$i.$rng";
      i+=1;
    });
  }

  @override
  void dispose() {
    print("wss closed");
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
          _textController.text = message + '\n' + _textController.text; // Ajouter une nouvelle ligne
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
    
    return PageStructure(body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:<Widget>[
              Center(child: Text("Object $object")),
              Expanded(                               
                        child: Center(
                            child : Stack(
                                alignment: Alignment.center,
                                children: [
                                    Image.network(_imageUrl, gaplessPlayback: true,),
                                    Positioned(
                                      top: 0, // Position verticale du bouton par rapport au haut de l'écran
                                      left: 0, // Position horizontale du bouton par rapport à la gauche de l'écran
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // Action à effectuer lors du clic sur le bouton
                                          setState(() {
                                            _isConfigVisible = ! _isConfigVisible;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                             backgroundColor: Colors.black.withOpacity(0.5), // Couleur semi-transparente
                                        ),
                                        child: Opacity(
                                              opacity: 0.5, // Opacité de l'icône (0.0 à 1.0)
                                              child: const Icon(
                                                             Icons.display_settings,
                                              )
                                        )
                                        
                                      ),
                                    ),
                                    if (_isConfigVisible)
                                        Positioned(
                                        
                                        left: 0, // Position horizontale du bouton par rapport à la gauche de l'écran
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Action à effectuer lors du clic sur le bouton
                                            print('Bouton 1 cliqué!');
                                          },
                                          style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.black.withOpacity(0.5), // Couleur semi-transparente
                                          ),
                                          child: Opacity(
                                                opacity: 0.5, // Opacité de l'icône (0.0 à 1.0)
                                                child: const Icon(
                                                                Icons.chevron_left,
                                                                size: 48.0
                                                )
                                          )
                                          
                                        ),
                                      ),
                                       if (_isConfigVisible) 
                                        Positioned(
                                          top:0,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              // Action à effectuer lors du clic sur le bouton
                                              print('Bouton 1 cliqué!');
                                            },
                                            style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.black.withOpacity(0.5), // Couleur semi-transparente
                                            ),
                                            child: Opacity(
                                                  opacity: 0.5, // Opacité de l'icône (0.0 à 1.0)
                                                  child: const Icon(
                                                                  Icons.expand_less,
                                                                  size: 48.0
                                                  )
                                            )
                                            
                                          ),
                                        ),
                                       if (_isConfigVisible)
                                        Positioned(
                                        
                                        right: 0, // Position horizontale du bouton par rapport à la gauche de l'écran
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Action à effectuer lors du clic sur le bouton
                                            print('Bouton 1 cliqué!');
                                          },
                                          style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.black.withOpacity(0.5), // Couleur semi-transparente
                                          ),
                                          child: Opacity(
                                                opacity: 0.5, // Opacité de l'icône (0.0 à 1.0)
                                                child: const Icon(
                                                                Icons.navigate_next,
                                                                size: 48.0
                                                )
                                          )
                                          
                                        ),
                                      ),
                                       if (_isConfigVisible)
                                        Positioned(
                                        
                                        bottom: 0, // Position horizontale du bouton par rapport à la gauche de l'écran
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Action à effectuer lors du clic sur le bouton
                                            print('Bouton 1 cliqué!');
                                          },
                                          style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.black.withOpacity(0.5), // Couleur semi-transparente
                                          ),
                                          child: Opacity(
                                                opacity: 0.5, // Opacité de l'icône (0.0 à 1.0)
                                                child: const Icon(
                                                                Icons.keyboard_arrow_down,
                                                                size: 48.0
                                                )
                                          )
                                          
                                        ),
                                      )
                                  ,
                                  if (_isStackable) 
                                     Positioned(
                                        bottom: 0, // Position horizontale du bouton par rapport à la gauche de l'écran
                                        right : 0,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Action à effectuer lors du clic sur le bouton
                                            print('Bouton stack cliqué!');
                                            _setStackable(false);
                                            service.stackImage(object);
                                          },
                                          style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.black.withOpacity(0.5), // Couleur semi-transparente
                                          ),
                                          child: Opacity(
                                                opacity: 0.5, // Opacité de l'icône (0.0 à 1.0)
                                                child: const Icon(
                                                                Icons.library_add,
                                                                size: 100.0
                                                )
                                          )
                                          
                                        ),
                                      )
                                ])
                        )
              ),
              Center(child: ScrollableTextField(
                controller: _textController,
              ))             
    ]));
  }


} 