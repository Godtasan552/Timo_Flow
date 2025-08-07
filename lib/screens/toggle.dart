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

  // แสดง confirmation dialog ก่อน complete all
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
        .where(
          (t) => t.type == TaskType.goal && t.userId == userId && !t.isDone,
        )
        .toList();

    for (var task in goalTasks) {
      final updatedTask = task.copyWith(
        isDone: true,
        completedDate: DateTime.now(),
      );
      await taskController.updateTask(updatedTask);
    }
  }

  void _toggleTaskDone(Task task) {
    final updatedTask = task.copyWith(
      isDone: !task.isDone,
      completedDate: !task.isDone ? DateTime.now() : null,
      clearCompletedDate:
          task.isDone, // ถ้า task เป็น done อยู่แล้ว จะเคลียร์ completedDate
    );
    taskController.updateTask(updatedTask);
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
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
                onPressed: hasUnfinishedTasks
                    ? _showCompleteAllConfirmation
                    : null,
                icon: const Icon(Icons.done_all, size: 18),
                label: const Text(
                  'Complete All',
                  style: TextStyle(fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasUnfinishedTasks
                      ? Colors.green
                      : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
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
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
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
              return _buildTaskCard(task);
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
        onTap: () {
          Get.to(() => TaskDetail(task: task));
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            border: task.isDone
                ? Border.all(color: Colors.grey.shade300, width: 1)
                : Border.all(color: const Color(0xFFF5DDFF), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row - Title and Toggle Button
              Row(
                children: [
                  // Task Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: task.isDone
                          ? Colors.grey.shade300
                          : const Color(0xFFF5DDFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.flag,
                      color: task.isDone
                          ? Colors.grey.shade600
                          : const Color(0xFFFFBDBD),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Title
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: task.isDone
                            ? Colors.grey.shade600
                            : Colors.black87,
                        decoration: task.isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),

                  // Toggle Button
                  GestureDetector(
                    onTap: () => _toggleTaskDone(task),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: task.isDone
                            ? Colors.green.withOpacity(0.2)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        task.isDone
                            ? Icons.check_circle
                            : Icons.check_circle_outline,
                        color: task.isDone
                            ? Colors.green
                            : Colors.grey.shade400,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),

              // Description (if exists)
              if (task.description != null && task.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  task.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: task.isDone
                        ? Colors.grey.shade500
                        : Colors.grey.shade700,
                    decoration: task.isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Completed Date (if task is done)
              if (task.isDone && task.completedDate != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Completed: ${_formatDate(task.completedDate!)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Date and Time Information
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: task.isDone
                      ? Colors.grey.shade50
                      : const Color(0xFFFFE1E0).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: task.isDone
                        ? Colors.grey.shade200
                        : const Color(0xFFFFE1E0),
                  ),
                ),
                child: Column(
                  children: [
                    // Date Row
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: task.isDone
                              ? Colors.grey.shade600
                              : const Color(0xFFFFBDBD),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Date: ${_formatDate(task.date)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: task.isDone
                                ? Colors.grey.shade600
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),

                    // Time Information
                    if (!task.isAllDay &&
                        (task.startTime != null || task.endTime != null)) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 18,
                            color: task.isDone
                                ? Colors.grey.shade600
                                : const Color(0xFFFFBDBD),
                          ),
                          const SizedBox(width: 8),
                          if (task.startTime != null && task.endTime != null)
                            Text(
                              'Time: ${_formatTime(task.startTime!)} - ${_formatTime(task.endTime!)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: task.isDone
                                    ? Colors.grey.shade600
                                    : Colors.black87,
                              ),
                            )
                          else if (task.startTime != null)
                            Text(
                              'Start time: ${_formatTime(task.startTime!)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: task.isDone
                                    ? Colors.grey.shade600
                                    : Colors.black87,
                              ),
                            )
                          else if (task.endTime != null)
                            Text(
                              'End time: ${_formatTime(task.endTime!)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: task.isDone
                                    ? Colors.grey.shade600
                                    : Colors.black87,
                              ),
                            ),
                        ],
                      ),
                    ] else if (task.isAllDay) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.all_inclusive,
                            size: 18,
                            color: task.isDone
                                ? Colors.grey.shade600
                                : const Color(0xFFFFBDBD),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'All Day',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: task.isDone
                                  ? Colors.grey.shade600
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Bottom Row - Category, Focus Mode, Notifications
              Row(
                children: [
                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: task.isDone
                          ? Colors.grey.shade300
                          : const Color(0xFFF5DDFF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      task.category,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: task.isDone
                            ? Colors.grey.shade600
                            : const Color(0xFFFFBDBD),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Focus Mode
                  if (task.focusMode)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: task.isDone
                            ? Colors.grey.shade300
                            : Colors.orange.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.psychology,
                            size: 12,
                            color: task.isDone
                                ? Colors.grey.shade600
                                : Colors.orange.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Focus',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: task.isDone
                                  ? Colors.grey.shade600
                                  : Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Spacer(),

                  // Notifications
                  if (task.notifyBefore.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: task.isDone
                            ? Colors.grey.shade300
                            : const Color(0xFFFFE1E0),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.notifications,
                            size: 12,
                            color: task.isDone
                                ? Colors.grey.shade600
                                : const Color(0xFFFFBDBD),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${task.notifyBefore.length}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: task.isDone
                                  ? Colors.grey.shade600
                                  : const Color(0xFFFFBDBD),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
