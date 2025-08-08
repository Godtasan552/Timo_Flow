import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/tasks_model.dart';
import '../services/storage_service_mobile.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'edit_task.dart';
import '../controllers/task_controller.dart';
import '../screens/search.dart';
import '../screens/toggle.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';

class TaskDetail extends StatefulWidget {
  final Task task;

  const TaskDetail({super.key, required this.task});

  @override
  State<TaskDetail> createState() => _TaskDetailState();
}

class _TaskDetailState extends State<TaskDetail> with TickerProviderStateMixin {
  late Duration remainingTime;
  Timer? timer;
  final TaskController _taskController = Get.find<TaskController>();
  late AnimationController _pulseController;

  // Color scheme
  static const Color primaryPastel = Color(0xFFE8D5FF);
  static const Color backgroundPastel = Color(0xFFF8F6FF);
  static const Color cardPastel = Color(0xFFFFFBFF);
  static const Color accentBlue = Color(0xFFE3F2FD);
  static const Color accentPink = Color(0xFFFFE4E6);
  static const Color accentPurple = Color(0xFFF3E5F5);

  Task get currentTask {
    final updatedTask = _taskController.tasks.firstWhere(
      (task) => task.id == widget.task.id,
      orElse: () => widget.task,
    );
    return updatedTask;
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _startCountdownIfNeeded();
  }

  void _startCountdownIfNeeded() {
    if (currentTask.focusMode == true &&
        currentTask.startTime != null &&
        currentTask.endTime != null) {
      _startCountdown();
    }
  }

  void _startCountdown() {
    final now = DateTime.now();

    DateTime endDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      currentTask.endTime!.hour,
      currentTask.endTime!.minute,
    );

    if (endDateTime.isBefore(now)) {
      endDateTime = endDateTime.add(const Duration(days: 1));
    }

    remainingTime = endDateTime.difference(now);

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        final newRemaining = endDateTime.difference(DateTime.now());
        if (newRemaining.isNegative) {
          remainingTime = Duration.zero;
          timer?.cancel();
        } else {
          remainingTime = newRemaining;
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildTag(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: textColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getTaskTypeColor(TaskType type, bool isBackground) {
    switch (type) {
      case TaskType.even:
        return isBackground ? accentPink : const Color(0xFFD81B60);
      case TaskType.goal:
        return isBackground ? accentBlue : const Color(0xFF0288D1);
      case TaskType.birthday:
        return isBackground ? accentPurple : const Color(0xFF8E24AA);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundPastel,
      // ใน TaskDetail - AppBar ที่ปรับปรุงแล้ว
      appBar: AppBar(
        backgroundColor: primaryPastel,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF6B4EFF)),
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF6B4EFF),
              size: 22,
            ),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            splashRadius: 20,
          ),
        ),
        title: const Text(
          'Task Details',
          style: TextStyle(
            color: Color(0xFF6B4EFF),
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 0.3,
          ),
        ),
        actions: [
          // Search Button
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.search,
                color: Color(0xFF6B4EFF),
                size: 22,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchScreen()),
                );
              },
              padding: EdgeInsets.zero,
              splashRadius: 20,
            ),
          ),
          // Toggle Button
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.check_box,
                color: Color(0xFF6B4EFF),
                size: 22,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ToggleScreen()),
                );
              },
              padding: EdgeInsets.zero,
              splashRadius: 20,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final task = currentTask;
          final dateText = DateFormat('EEEE, MMMM d, yyyy').format(task.date);
          final timeRange = task.startTime != null && task.endTime != null
              ? '${task.startTime!.hour.toString().padLeft(2, '0')}:${task.startTime!.minute.toString().padLeft(2, '0')} - ${task.endTime!.hour.toString().padLeft(2, '0')}:${task.endTime!.minute.toString().padLeft(2, '0')}'
              : task.isAllDay
              ? 'All Day'
              : 'No time';

          final bgColor = _getTaskTypeColor(task.type, true);
          final accentColor = _getTaskTypeColor(task.type, false);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Main Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardPastel,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with tags and time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildTag(task.type.name, bgColor, accentColor),
                                _buildTag(
                                  task.category,
                                  const Color(0xFFFFF3E0),
                                  const Color(0xFFEF6C00),
                                ),
                                if (task.focusMode)
                                  _buildTag(
                                    'Focus Mode',
                                    const Color(0xFFFFEBEE),
                                    const Color(0xFFD32F2F),
                                  ),
                              ],
                            ),
                          ),
                          if (!task.isAllDay)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentColor.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                timeRange,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: accentColor,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Title
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D),
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Date
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: primaryPastel.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Color(0xFF6B4EFF),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              dateText,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF6B4EFF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Description
                      if (task.description != null &&
                          task.description!.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE9ECEF),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'DESCRIPTION',
                                style: TextStyle(
                                  color: Color(0xFF6B4EFF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                task.description!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: Color(0xFF495057),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Focus Mode Timer
                      if (task.focusMode == true)
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: remainingTime > Duration.zero
                                  ? 1.0 + (_pulseController.value * 0.05)
                                  : 1.0,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: remainingTime > Duration.zero
                                        ? [
                                            const Color(0xFFFFEBEE),
                                            const Color(0xFFFCE4EC),
                                          ]
                                        : [
                                            const Color(0xFFE8F5E8),
                                            const Color(0xFFC8E6C9),
                                          ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          (remainingTime > Duration.zero
                                                  ? const Color(0xFFD32F2F)
                                                  : const Color(0xFF2E7D32))
                                              .withOpacity(0.1),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      remainingTime > Duration.zero
                                          ? Icons.timer
                                          : Icons.check_circle,
                                      size: 40,
                                      color: remainingTime > Duration.zero
                                          ? const Color(0xFFD32F2F)
                                          : const Color(0xFF2E7D32),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      remainingTime > Duration.zero
                                          ? 'Focus Mode Active'
                                          : 'Focus Session Complete!',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: remainingTime > Duration.zero
                                            ? const Color(0xFFD32F2F)
                                            : const Color(0xFF2E7D32),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      remainingTime > Duration.zero
                                          ? formatDuration(remainingTime)
                                          : 'Well done! 🎉',
                                      style: TextStyle(
                                        fontSize: remainingTime > Duration.zero
                                            ? 32
                                            : 24,
                                        fontWeight: FontWeight.bold,
                                        color: remainingTime > Duration.zero
                                            ? const Color(0xFFD32F2F)
                                            : const Color(0xFF2E7D32),
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 56,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFE0B2),
                            foregroundColor: const Color(0xFFEF6C00),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.edit, size: 20),
                          label: const Text(
                            'Edit',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: () async {
                            await Get.to(() => EditTaskPage(task: task));
                            timer?.cancel();
                            _startCountdownIfNeeded();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 56,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFCDD2),
                            foregroundColor: const Color(0xFFD32F2F),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.delete, size: 20),
                          label: const Text(
                            'Delete',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: _showDeleteConfirmDialog,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Mark Done Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC8E6C9),
                      foregroundColor: const Color(0xFF2E7D32),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.close, size: 20),
                    label: const Text(
                      'Close',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: _markTaskDone,
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardPastel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Delete Task',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF6B4EFF),
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${currentTask.title}"? This action cannot be undone.',
            style: const TextStyle(fontSize: 16, color: Color(0xFF495057)),
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
                _deleteTask();
              },
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
        );
      },
    );
  }

  void _deleteTask() async {
    try {
      _taskController.deleteTaskById(currentTask.id);

      if (mounted) {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.success(
            message: 'Task "${currentTask.title}" deleted successfully',
          ),
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    } catch (error) {
      if (mounted) {
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.error(
            message: 'Failed to delete task. Please try again.',
          ),
        );
      }
    }
  }

  void _markTaskDone() async {
    try {
      final updatedTask = Task(
        id: currentTask.id,
        userId: currentTask.userId,
        title: currentTask.title,
        description: currentTask.description,
        category: currentTask.category,
        date: currentTask.date,
        startTime: currentTask.startTime,
        endTime: currentTask.endTime,
        isAllDay: currentTask.isAllDay,
        notifyBefore: currentTask.notifyBefore,
        focusMode: currentTask.focusMode,
        isDone: true,
        type: currentTask.type,
      );

      await _taskController.updateTask(updatedTask);

      if (mounted) {
        // showTopSnackBar(
        //   Overlay.of(context),
        //   const CustomSnackBar.success(message: 'Task marked as complete'),
        // );

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    } catch (error) {
      if (mounted) {
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.error(
            message: 'Failed to mark task as complete. Please try again.',
          ),
        );
      }
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }
}
