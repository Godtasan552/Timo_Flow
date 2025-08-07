import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../controllers/auth_controller.dart';
import '../model/tasks_model.dart';
import 'task_detail.dart'; // <- หน้าที่แสดงรายละเอียด task

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

  void _markAllDone() {
    final userId = authController.currentUser.value?.id;
    final goalTasks = taskController.tasks
        .where((t) => t.type == TaskType.goal && t.userId == userId)
        .toList();

    for (var task in goalTasks) {
      if (!task.isDone) {
        final updatedTask = Task(
          id: task.id,
          userId: task.userId,
          title: task.title,
          description: task.description,
          category: task.category,
          date: task.date,
          startTime: task.startTime,
          endTime: task.endTime,
          isAllDay: task.isAllDay,
          notifyBefore: task.notifyBefore,
          focusMode: task.focusMode,
          isDone: true,
          type: task.type,
        );
        taskController.updateTask(updatedTask);
      }
    }
  }

  void _toggleTaskDone(Task task) {
    final updatedTask = Task(
      id: task.id,
      userId: task.userId,
      title: task.title,
      description: task.description,
      category: task.category,
      date: task.date,
      startTime: task.startTime,
      endTime: task.endTime,
      isAllDay: task.isAllDay,
      notifyBefore: task.notifyBefore,
      focusMode: task.focusMode,
      isDone: !task.isDone,
      type: task.type,
    );
    taskController.updateTask(updatedTask);
  }

  @override
  Widget build(BuildContext context) {
    final userId = authController.currentUser.value?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Toggle Goals"),
        actions: [
          IconButton(icon: const Icon(Icons.done_all), onPressed: _markAllDone),
        ],
      ),
      body: Obx(() {
        final goalTasks = taskController.tasks
            .where((t) => t.type == TaskType.goal && t.userId == userId)
            .toList();

        final unfinished = goalTasks.where((t) => !t.isDone).toList();
        final finished = goalTasks.where((t) => t.isDone).toList();

        final allTasks = [...unfinished, ...finished];

        if (allTasks.isEmpty) {
          return const Center(child: Text("No goals found."));
        }

        return ListView.builder(
          itemCount: allTasks.length,
          itemBuilder: (context, index) {
            final task = allTasks[index];
            final isDone = task.isDone;

            return ListTile(
              title: Text(
                task.title,
                style: TextStyle(
                  decoration: isDone
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: isDone ? Colors.grey : null,
                ),
              ),
              trailing: Checkbox(
                value: isDone,
                onChanged: (_) => _toggleTaskDone(task),
              ),
              onTap: () {
                // ไปหน้า detail
                Get.to(() => TaskDetail(task: task));
              },
            );
          },
        );
      }),
    );
  }
}
