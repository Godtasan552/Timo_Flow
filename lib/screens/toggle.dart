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

class _ToggleScreenState extends State<ToggleScreen>
    with TickerProviderStateMixin {
  final TaskController taskController = Get.find<TaskController>();
  final AuthController authController = Get.find<AuthController>();
  late AnimationController _completionAnimationController;

  // Color scheme
  static const Color primaryPastel = Color(0xFFE8D5FF);
  static const Color backgroundPastel = Color(0xFFF8F6FF);
  static const Color cardPastel = Color(0xFFFFFBFF);
  static const Color accentBlue = Color(0xFFE3F2FD);
  static const Color completedGreen = Color(0xFFE8F5E8);

  @override
  void initState() {
    super.initState();
    _completionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    final userId = authController.currentUser.value?.id;
    if (userId != null) {
      taskController.loadTasksForUser(userId);
    }
  }

  @override
  void dispose() {
    _completionAnimationController.dispose();
    super.dispose();
  }

  void _showCompleteAllConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardPastel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: completedGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.done_all,
                  color: Color(0xFF2E7D32),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Complete All Tasks',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B4EFF),
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to complete all unfinished goal tasks? This action cannot be undone.',
            style: TextStyle(fontSize: 16, color: Color(0xFF495057)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _markAllDone();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Complete All',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
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

    _completionAnimationController.forward().then((_) {
      _completionAnimationController.reverse();
    });
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

  @override
  Widget build(BuildContext context) {
    final userId = authController.currentUser.value?.id;

    return Scaffold(
      backgroundColor: backgroundPastel,
      appBar: AppBar(
        title: const Text(
          "Goal Tasks",
          style: TextStyle(
            color: Color(0xFF6B4EFF),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryPastel,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF6B4EFF)),
        actions: [
          Obx(() {
            final goalTasks = taskController.tasks
                .where((t) => t.type == TaskType.goal && t.userId == userId)
                .toList();
            final hasUnfinishedTasks = goalTasks.any((task) => !task.isDone);
            return Container(
              margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              child: AnimatedBuilder(
                animation: _completionAnimationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_completionAnimationController.value * 0.1),
                    child: ElevatedButton.icon(
                      onPressed: hasUnfinishedTasks ? _showCompleteAllConfirmation : null,
                      icon: const Icon(Icons.done_all, size: 18),
                      label: const Text(
                        'Complete All',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasUnfinishedTasks 
                          ? const Color(0xFF2E7D32) 
                          : const Color(0xFF9E9E9E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                    ),
                  );
                },
              ),
            );
          }),
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: primaryPastel.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.flag_outlined,
                    size: 80,
                    color: Color(0xFF6B4EFF),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "No Goal Tasks Found",
                  style: TextStyle(
                    fontSize: 22,
                    color: Color(0xFF6B4EFF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Create your first goal task to get started!",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF9E9E9E),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: allTasks.length,
          itemBuilder: (context, index) {
            final task = allTasks[index];
            return Dismissible(
              key: Key(task.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCDD2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete,
                      color: Color(0xFFD32F2F),
                      size: 28,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Delete',
                      style: TextStyle(
                        color: Color(0xFFD32F2F),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: cardPastel,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text(
                      'Confirm Deletion',
                      style: TextStyle(
                        color: Color(0xFF6B4EFF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    content: const Text(
                      'Are you sure you want to delete this task? This action cannot be undone.',
                      style: TextStyle(color: Color(0xFF495057)),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF9E9E9E),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
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
    );
  }

  Widget _buildTaskCard(Task task) {
    final isCompleted = task.isDone;
    final bgColor = isCompleted ? completedGreen : accentBlue;
    final accentColor = isCompleted 
      ? const Color(0xFF2E7D32) 
      : const Color(0xFF0288D1);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.to(() => TaskDetail(task: task)),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Status Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _toggleTaskDone(task),
                      borderRadius: BorderRadius.circular(24),
                      child: Icon(
                        isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: accentColor,
                        size: 28,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Task Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                          decoration: isCompleted 
                            ? TextDecoration.lineThrough 
                            : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (task.description != null && task.description!.isNotEmpty) ...[
                        Text(
                          task.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: accentColor.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              task.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: accentColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _formatDate(task.date),
                              style: TextStyle(
                                fontSize: 12,
                                color: accentColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (isCompleted && task.completedDate != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: accentColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Completed ${_formatDate(task.completedDate!)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: accentColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Time or Arrow Icon
                if (task.startTime != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      '${task.startTime!.hour.toString().padLeft(2, '0')}:${task.startTime!.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                        fontSize: 14,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      color: accentColor,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}