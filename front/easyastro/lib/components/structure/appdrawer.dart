import 'package:flutter/material.dart';
import 'package:easyastro/services/database/globals.dart';
import 'package:easyastro/services/database/configmanager.dart';
import 'package:easy_localization/easy_localization.dart';

class AppDrawer extends Drawer {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(''),
          ),
          ListTile(
            leading: const Icon(
              Icons.home,
            ),
            title: const Text('home').tr(),
            onTap: () {
              //Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.add_task,
            ),
            title: const Text('plan').tr(),
            onTap: () {
              //Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/plan');
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.explore,
            ),
            title: const Text('selected').tr(),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/selection');
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.map,
            ),
            title: const Text('map').tr(),
            onTap: () {
              //Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/map');
            },
          ),
          if (ConfigManager().configuration?["manageTelescope"]?.value == true)
            ServerInfo().connected
                ? ListTile(
                    leading: const Icon(
                      Icons.visibility,
                    ),
                    title: Text('observe').tr(),
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/capture');
                    },
                  )
                : ListTile(
                    leading: const Icon(
                      Icons.visibility,
                    ),
                    title: Text('connect').tr(),
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/connect');
                    },
                  ),
          ListTile(
            leading: const Icon(
              Icons.settings,
            ),
            title: const Text('config').tr(),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/config');
            },
          ),
          ServerInfo().connected
              ? ListTile(
                  leading: const Icon(
                    Icons.power_settings_new,
                  ),
                  title: const Text('Disconnect'),
                  onTap: () {
                    ServerInfo().connected = false;
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                )
              : Container(width: 0, height: 0),
        ],
      ),
    );
  }
}
