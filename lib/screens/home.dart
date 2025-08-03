import 'package:flutter/material.dart';
import '../components/drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('หน้าหลัก')),
      drawer: const MyDrawer(),
      body: const Center(child: Text('ยินดีต้อนรับสู่หน้าหลัก!')),
    );
  }
}
