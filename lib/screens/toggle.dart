import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../controllers/auth_controller.dart';
import '../model/tasks_model.dart';
import 'task_detail.dart';

class ToggleScreen extends StatefulWidget {
  const ToggleScreen({Key? key}) : super(key: key);

  @override
  State<ToggleScreen> createState() => _ToggleScreenState();
}

class _ToggleScreenState extends State<ToggleScreen> {
  final TaskController taskController = Get.find<TaskController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    final userId = authController.currentUser.value?.id;
    if (userId != null) {
      taskController.loadTasksForUser(userId);
    }
  }

  void _showCompleteAllConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.done_all, color: Colors.green),
              SizedBox(width: 8),
              Text('Complete All Tasks'),
            ],
          ),
          content: const Text(
            'Are you sure you want to complete all unfinished goal tasks?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _markAllDone();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Complete All'),
            ),
          ],
        );
      },
    );
  }

  void _markAllDone() async {
    final userId = authController.currentUser.value?.id;
    if (userId == null) return;

    final goalTasks = taskController.tasks
        .where((t) => t.type == TaskType.goal && t.userId == userId && !t.isDone)
        .toList();

    for (var task in goalTasks) {
      task.isDone = true;
      task.completedDate = DateTime.now();
      await taskController.updateTask(task);
    }
  }

  void _toggleTaskDone(Task task) async {
    if (task.isDone) {
      task.isDone = false;
      task.completedDate = null;
    } else {
      task.isDone = true;
      task.completedDate = DateTime.now();
    }
    await taskController.updateTask(task);
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final userId = authController.currentUser.value?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Goal Tasks",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFFBDBD),
        elevation: 0,
        actions: [
          Obx(() {
            final goalTasks = taskController.tasks
                .where((t) => t.type == TaskType.goal && t.userId == userId)
                .toList();
            final hasUnfinishedTasks = goalTasks.any((task) => !task.isDone);
            return Container(
              margin: const EdgeInsets.only(right: 8),
              child: ElevatedButton.icon(
                onPressed: hasUnfinishedTasks ? _showCompleteAllConfirmation : null,
                icon: const Icon(Icons.done_all, size: 18),
                label: const Text(
                  'Complete All',
                  style: TextStyle(fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasUnfinishedTasks ? Colors.green : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            );
          }),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5DDFF), Color(0xFFFFBDBD), Color(0xFFFFE1E0)],
          ),
        ),
        child: Obx(() {
          final goalTasks = taskController.tasks
              .where((t) => t.type == TaskType.goal && t.userId == userId)
              .toList();
          final unfinished = goalTasks.where((t) => !t.isDone).toList();
          final finished = goalTasks.where((t) => t.isDone).toList();
          final allTasks = [...unfinished, ...finished];

          if (allTasks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flag_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No goal tasks found",
                    style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: allTasks.length,
            itemBuilder: (context, index) {
              final task = allTasks[index];
              return Dismissible(
                key: Key(task.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirm'),
                      content: const Text('Are you sure you want to delete this task?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (_) {
                  final userId = taskController.authController.currentUser.value?.id;
                  if (userId != null) {
                    taskController.deleteTask(task.id, userId);
                  }
                },
                child: _buildTaskCard(task),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: task.isDone ? 2 : 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: InkWell(
        onTap: () => Get.to(() => TaskDetail(task: task)),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: task.isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (task.description != null && task.description!.isNotEmpty)
                      Text(
                        task.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(task.date),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  task.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: task.isDone ? Colors.green : Colors.grey,
                ),
                onPressed: () => _toggleTaskDone(task),
              ),
            ],
          ),
        ),
      ),
    );
  }
}