import 'package:flutter/material.dart';
import 'package:front_test/components/pagestructure.dart';
import 'package:front_test/services/protocol.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:front_test/services/globals.dart';
import 'package:front_test/services/servicecheck.dart';
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

  final ServiceCheckHelper service = ServiceCheckHelper();


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
      if (info['refreshImage']) {
        fetchImage();
      }
    });
    // Récupérer l'image initiale depuis l'API
    fetchImage();
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
        }
      }
    }

    return PageStructure(body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:<Widget>[
                            Center(child: Text("Object $object")),
                            Expanded(                               
                                      child: Center(child : Image.network(_imageUrl, gaplessPlayback: true,))
                            )
            
                            
    ]));
  }
} 