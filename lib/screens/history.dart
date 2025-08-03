import 'package:flutter/material.dart';
import '../components/drawer.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      drawer: const MyDrawer(),
      body: const Center(child: Text('welcome to the History Page!')),
    );
  }
}
