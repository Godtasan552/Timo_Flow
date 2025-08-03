import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timo Flow Home'),
      ),
      body: const Center(
        child: Text(
          'ยินดีต้อนรับสู่หน้า Home\n(เพิ่ม Calendar + Task ที่นี่)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}