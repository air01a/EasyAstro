import 'package:flutter/material.dart'; 
import 'package:easyastro/services/globals.dart';
import 'package:easyastro/services/configmanager.dart';
import 'package:easy_localization/easy_localization.dart';

class AppDrawer extends Drawer{
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
                        Navigator.pushNamed(context, '/home');
                      },
                      ),ListTile(
                      leading: const Icon(
                        Icons.add_task,
                      ),
                      title: const Text('plan').tr(),
                      onTap: () {
                        //Navigator.pop(context);
                        Navigator.pushNamed(context, '/plan');
                      },
                      ),
                      ListTile(
                      leading: const Icon(
                        Icons.explore,
                      ),
                      title: const Text('selected').tr(),
                      onTap: () {
                        Navigator.pushNamed(context, '/selection');
                      },
                      ),
                      if (ConfigManager().configuration?["manageTelescope"]?.value==true)
                      ServerInfo().connected
                        ? ListTile(
                        leading: const Icon(
                          Icons.visibility,
                        ),
                        title: Text('observe').tr(),
                        onTap: () {
                          Navigator.pushNamed(context, '/capture');
                        },
                        )
                        : ListTile(
                        leading: const Icon(
                          Icons.visibility,
                        ),
                        title: Text('connect').tr(),
                        onTap: () {
                          Navigator.pushNamed(context, '/connect');
                        },
                        ),
                      ListTile(
                      leading: const Icon(
                        Icons.settings,
                      ),
                      title: const Text('config').tr(),
                      onTap: () {
                        Navigator.pushNamed(context, '/config');
                      },
                      ), ServerInfo().connected
                      ? ListTile(
                      leading: const Icon(
                        Icons.power_settings_new,
                      ),
                      title: const Text('shutdown'),
                      onTap: () {
                        Navigator.pushNamed(context, '/shutdown');
                      },
                      ) 
                      : Container(width: 0, height: 0)
                      ,
                      ListTile(
                      leading: const Icon(
                        Icons.logout,
                      ),
                      
                      title: const Text('quit'),
                      onTap: () {
                        Navigator.pushNamed(context, '/');
                      },
                      ),
                    ],
                    ),
                  );

  }
}