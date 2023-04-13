import 'package:flutter/material.dart';
import 'package:front_test/components/pagestructure.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'package:front_test/services/globals.dart';

class ScreenCapture extends StatefulWidget {
  @override
  _ScreenCapture createState() => _ScreenCapture();
}

class _ScreenCapture extends State<ScreenCapture> {
  String _imageUrl = '';
  String object ="";
  final channel = WebSocketChannel .connect(Uri.parse("ws://${ServerInfo().host}/telescope/ws/1234"));

  void fetchImage() async {
    //print("${ServerInfo().host}/telescope/last_picture");
    //final response = await http.get(Uri.parse("${ServerInfo().host}/telescope/last_picture"));
    setState(() {
      _imageUrl = "http://${ServerInfo().host}/telescope/last_picture";
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
      print("wss recveived");
      fetchImage();
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
        object = args['object'] ;
      }
    }

    return PageStructure(body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:<Widget>[
                            Center(child: Text("Object $object")),
                            Center(child: Image.network(_imageUrl)),
    ]));
  }
}