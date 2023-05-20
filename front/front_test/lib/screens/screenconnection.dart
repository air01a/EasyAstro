import 'package:flutter/material.dart';
import 'package:front_test/services/globals.dart';
import 'package:front_test/services/persistentdata.dart';

class ConnectionPage extends StatefulWidget {

  const ConnectionPage({super.key});
  @override
  State<ConnectionPage> createState() => _ConnectionPage();
}

class _ConnectionPage extends State<ConnectionPage> {
  final _formKey = GlobalKey<FormState>();
  PersistentData localData = PersistentData();
  late String? _server ='';
  final TextEditingController _controller = TextEditingController();

Future<void> _loadSavedIpAddress() async {
    String? savedIpAddress = await localData.getValue('host');
    if (savedIpAddress != null) {
      _controller.text = savedIpAddress;
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadSavedIpAddress();
  }

  @override
  Widget build(BuildContext context)  {
   print("build : $_server");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection'),  
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
              TextFormField(
                validator: (value) {
                  if (value==null || value.isEmpty) {
                    return 'Please enter the server URL';
                  }
                  return null;
                },
                onSaved: (String? value) {
                  _server = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Server',
                ),
                controller : _controller,
              ),
        
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Save the data to a database or process it in some other way
                      
                      ServerInfo().host = _server ?? '';
                      localData.saveValue('host', _server??'');
                      Navigator.pushNamed(context, '/check');
                      /*showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Success!'),
                            content: Text('Your server is $_server and'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                   
                                },
                              ),
                            ],
                          );
                        },
                      );*/
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
