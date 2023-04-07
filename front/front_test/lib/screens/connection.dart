import 'package:flutter/material.dart';
import 'package:front_test/services/globals.dart';

class ConnectionPage extends StatefulWidget {

  const ConnectionPage({super.key});
  @override
  State<ConnectionPage> createState() => _ConnectionPage();
}

class _ConnectionPage extends State<ConnectionPage> {
  final _formKey = GlobalKey<FormState>();
  String? _server="";


  @override
  Widget build(BuildContext context) {
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
              ),
        
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Save the data to a database or process it in some other way
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Success!'),
                            content: Text('Your server is $_server and'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                   ServerInfo().host = _server ?? '';
                                   Navigator.pushNamed(context, '/home');
                                },
                              ),
                            ],
                          );
                        },
                      );
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
