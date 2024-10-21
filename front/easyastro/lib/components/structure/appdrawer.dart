import 'package:flutter/material.dart';
import 'package:easyastro/services/database/globals.dart';
import 'package:easyastro/services/database/configmanager.dart';
import 'package:easy_localization/easy_localization.dart';

class AppDrawer extends Drawer {
  const AppDrawer({super.key});

  void pushChange(BuildContext context, String page) {
    if (CurrentLocation().isSetup) {
      Navigator.pushReplacementNamed(context, page);
    } else {
      Navigator.pushReplacementNamed(context, '/check');

    }
  }

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
              pushChange(context, '/home');
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.add_task,
            ),
            title: const Text('plan').tr(),
            onTap: () {
              //Navigator.pop(context);
              pushChange(context, '/plan');
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.star,
            ),
            title: const Text('selected').tr(),
            onTap: () {
              pushChange(context, '/selection');
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.more_time,
            ),
            title: const Text('sidereal_hour').tr(),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/sidereal');
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.explore,
            ),
            title: const Text('compass').tr(),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/compass');
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.map,
            ),
            title: const Text('map').tr(),
            onTap: () {
              //Navigator.pop(context);
              pushChange(context, '/map');
            },
          ),
          if (ConfigManager().configuration?["manageTelescope"]?.value == true)
            ServerInfo().connected
                ? ListTile(
                    leading: const Icon(
                      Icons.visibility,
                    ),
                    title: const Text('observe').tr(),
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/capture');
                    },
                  )
                : ListTile(
                    leading: const Icon(
                      Icons.visibility,
                    ),
                    title: const Text('connect').tr(),
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
              : const SizedBox(width: 0, height: 0),
        ],
      ),
    );
  }
}
