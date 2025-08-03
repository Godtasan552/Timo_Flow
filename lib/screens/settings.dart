import 'package:flutter/material.dart';
import '../components/drawer.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      drawer: const MyDrawer(),
      body: const Center(child: Text('Welcome to the Settings Page!')),
    );
  }
}
