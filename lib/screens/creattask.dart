import 'package:flutter/material.dart';

class CreatTaskPage extends StatefulWidget {
  const CreatTaskPage({super.key});

  @override
  State<CreatTaskPage> createState() => _CreatTaskPageState();
}

class _CreatTaskPageState extends State<CreatTaskPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Task')),
      body: const Center(child: Text('welcome to the Create Task Page!')),
    );
  }
}
