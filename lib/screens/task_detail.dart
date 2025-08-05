import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/tasks_model.dart';

class TaskDetail extends StatelessWidget {
  final Task task;

  const TaskDetail({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('dd MMMM yyyy').format(task.date!);
    final timeText = task.startTime != null
        ? '${task.startTime!.hour.toString().padLeft(2, '0')}:${task.startTime!.minute.toString().padLeft(2, '0')}'
        : 'No time';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (task.description != null && task.description!.isNotEmpty)
                  Text(task.description!, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                Text('Date: $dateText'),
                Text('Time: $timeText'),
                Text('Type: ${task.type.name}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
