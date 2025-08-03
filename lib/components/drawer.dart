import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/home.dart';
import '../screens/history.dart';
import '../screens/settings.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color.fromARGB(255, 67, 255, 183)),
            child: Text('Drawer Header'),
          ),
          ListTile(
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const HomePage());
            },
          ),
          ListTile(
            title: const Text('History'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const HistoryPage());
            },
          ),
          ListTile(
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const SettingsPage());
            },
          ),
        ],
      ),
    );
  }
}
