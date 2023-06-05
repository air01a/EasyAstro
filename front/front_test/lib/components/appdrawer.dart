import 'package:flutter/material.dart'; 
import 'package:front_test/services/globals.dart';
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
                      title: const Text('Home'),
                      onTap: () {
                        //Navigator.pop(context);
                        Navigator.pushNamed(context, '/home');
                      },
                      ),ListTile(
                      leading: const Icon(
                        Icons.add_task,
                      ),
                      title: const Text('Plan'),
                      onTap: () {
                        //Navigator.pop(context);
                        Navigator.pushNamed(context, '/plan');
                      },
                      ),
                      ListTile(
                      leading: const Icon(
                        Icons.explore,
                      ),
                      title: const Text('Selected'),
                      onTap: () {
                        Navigator.pushNamed(context, '/selection');
                      },
                      ),
                      ServerInfo().connected
                        ? ListTile(
                        leading: const Icon(
                          Icons.visibility,
                        ),
                        title: Text('Observe'),
                        onTap: () {
                          Navigator.pushNamed(context, '/capture');
                        },
                        )
                        : ListTile(
                        leading: const Icon(
                          Icons.visibility,
                        ),
                        title: Text('Connect'),
                        onTap: () {
                          Navigator.pushNamed(context, '/connect');
                        },
                        ),
                      ListTile(
                      leading: const Icon(
                        Icons.settings,
                      ),
                      title: const Text('Config'),
                      onTap: () {
                        Navigator.pushNamed(context, '/config');
                      },
                      ), ServerInfo().connected
                      ? ListTile(
                      leading: const Icon(
                        Icons.power_settings_new,
                      ),
                      title: const Text('Shutdown'),
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
                      
                      title: const Text('Quit'),
                      onTap: () {
                        Navigator.pushNamed(context, '/');
                      },
                      ),
                    ],
                    ),
                  );

  }
}