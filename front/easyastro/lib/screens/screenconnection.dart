import 'package:flutter/material.dart';
import 'package:easyastro/services/database/globals.dart';
import 'package:easyastro/services/database/persistentdatahelper.dart';
import 'package:easyastro/services/telescope/telescopeHelper.dart';
import 'package:easy_localization/easy_localization.dart';
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
  String _error='';

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
              if (_error!='') Text(_error.tr(),  style: const TextStyle(fontSize: 10, color:Colors.red),),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Save the data to a database or process it in some other way
                      
                      ServerInfo().host = _server ?? '';
                      localData.saveValue('host', _server??'');
                      TelescopeHelper checkHelper = TelescopeHelper(ServerInfo().host);
                      await checkHelper.updateAPILocation();
                      if (checkHelper.helper.lastError==0) {
                        ServerInfo().connected = true;
                        Navigator.pushNamed(context, '/capture');
                      } else {
                        setState(() => _error=checkHelper.helper.lastErrorStr,);
                      }
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
