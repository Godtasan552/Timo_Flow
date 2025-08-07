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
          ListTile(
            title: const Text('Print data (debug)'),
            onTap: () async {
              Navigator.pop(context);
              final users = await StorageService.loadUsers();
              final tasks = await StorageService.loadTasks();
              final encoder = const JsonEncoder.withIndent('  ');
              final usersJson = encoder.convert(
                users.map((e) => e.toJson()).toList(),
              );
              final tasksJson = encoder.convert(
                tasks.map((e) => e.toJson()).toList(),
              );
              debugPrint(" Users:\n$usersJson");
              debugPrint(" Tasks:\n$tasksJson");
            },
          ),
        ],
      ),
    );
  }
}
