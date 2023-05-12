import 'package:flutter/material.dart'; 

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
                        Icons.add_task,
                      ),
                      title: const Text('Plan'),
                      onTap: () {
                        //Navigator.pop(context);
                        Navigator.pushNamed(context, '/home');
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
                      ListTile(
                      leading: const Icon(
                        Icons.visibility,
                      ),
                      title: const Text('Observe'),
                      onTap: () {
                        Navigator.pushNamed(context, '/capture');
                      },
                      ),
                      ListTile(
                      leading: const Icon(
                        Icons.logout,
                      ),
                      title: const Text('Logout'),
                      onTap: () {
                        Navigator.pushNamed(context, '/');
                      },
                      ),
                    ],
                    ),
                  );

  }
}