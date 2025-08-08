import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/home.dart';
import '../screens/history.dart';
import '../screens/settings.dart';
import '../services/storage_service_mobile.dart';
import 'dart:convert';

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
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 246, 232, 255),
            ),
            child: Text(
              'Timo Flow',
              style: TextStyle(
                fontSize: 24,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
          ListTile(
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const HomeScreen());
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
