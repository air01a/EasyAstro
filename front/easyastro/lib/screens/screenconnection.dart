import 'package:flutter/material.dart';
import 'package:easyastro/services/database/globals.dart';
import 'package:easyastro/services/database/persistentdatahelper.dart';
import 'package:easyastro/services/telescope/telescopehelper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easyastro/components/structure/pagestructure.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({super.key});
  @override
  State<ConnectionPage> createState() => _ConnectionPage();
}

class _ConnectionPage extends State<ConnectionPage> {
  final _formKey = GlobalKey<FormState>();
  PersistentData localData = PersistentData();
  late String? _server = '';
  final TextEditingController _controller = TextEditingController();
  String _error = '';
  final Uri _url = Uri.parse('https://github.com/air01a/EasyAstro');

  Future<void> _loadSavedIpAddress() async {
    String? savedIpAddress = await localData.getValue('host');
    if (savedIpAddress != null) {
      _controller.text = savedIpAddress;
    }
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadSavedIpAddress();
  }

  @override
  Widget build(BuildContext context) {
    return PageStructure(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'error_server_url'.tr();
                  }
                  return null;
                },
                onSaved: (String? value) {
                  _server = value;
                },
                decoration: InputDecoration(
                  labelText: 'server'.tr(),
                ),
                controller: _controller,
              ),
              if (_error != '')
                Text(
                  _error.tr(),
                  style: const TextStyle(fontSize: 10, color: Colors.red),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Save the data to a database or process it in some other way

                      ServerInfo().host = _server ?? '';
                      localData.saveValue('host', _server ?? '');
                      TelescopeHelper checkHelper =
                          TelescopeHelper(ServerInfo().host);
                      await checkHelper.updateAPILocation();
                      if (checkHelper.helper.lastError == 0) {
                        ServerInfo().connected = true;
                        Navigator.pushReplacementNamed(context, '/capture');
                      } else {
                        setState(
                          () => _error = checkHelper.helper.lastErrorStr,
                        );
                      }
                    }
                  },
                  child: const Text('submit').tr(),
                ),
              ),
              Center(
                  child: GestureDetector(
                onTap: () {
                  _launchUrl();
                },
                child: Text(
                  'click_doc'.tr(),
                  style: TextStyle(
                    color: Colors.blue, // Couleur du lien
                    decoration:
                        TextDecoration.underline, // Soulignement du lien
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
