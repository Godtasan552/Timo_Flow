import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/tasks_model.dart';
import '../services/storage_service_mobile.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'edit_task.dart';
import '../controllers/task_controller.dart';

class TaskDetail extends StatefulWidget {
  final Task task;

  const TaskDetail({super.key, required this.task});

  @override
  State<TaskDetail> createState() => _TaskDetailState();
}

class _TaskDetailState extends State<TaskDetail> {
  late Duration remainingTime;
  Timer? timer;
  final TaskController _taskController = Get.find<TaskController>();
  
  // เก็บ task ที่อัพเดตแล้ว
  Task get currentTask {
    // หา task ล่าสุดจาก controller
    final updatedTask = _taskController.tasks.firstWhere(
      (task) => task.id == widget.task.id,
      orElse: () => widget.task, // ถ้าไม่เจอให้ใช้ตัวเดิม
    );
    return updatedTask;
  }

  @override
  void initState() {
    super.initState();
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

    // สร้าง DateTime สำหรับ endTime
    DateTime endDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      currentTask.endTime!.hour,
      currentTask.endTime!.minute,
    );

    // ถ้าเวลาสิ้นสุดน้อยกว่าปัจจุบัน (ข้ามวัน)
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5DDFF), Color(0xFFFFE1E0), Color(0xFFFFBDBD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'task detail',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              // Main content - ใช้ Obx เพื่อฟังการเปลี่ยนแปลง
              Expanded(
                child: Obx(() {
                  final task = currentTask; // ได้ task ที่อัพเดตล่าสุด
                  final dateText = DateFormat('EEEE, MMMM d, yyyy').format(task.date);
                  final timeRange = task.startTime != null && task.endTime != null
                      ? '${task.startTime!.hour.toString().padLeft(2, '0')}:${task.startTime!.minute.toString().padLeft(2, '0')}-${task.endTime!.hour.toString().padLeft(2, '0')}:${task.endTime!.minute.toString().padLeft(2, '0')}'
                      : 'No time';

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Main Card
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Type Tag and Time Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE3F2FD),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          task.type.name,
                                          style: const TextStyle(
                                            color: Color(0xFF1976D2),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        timeRange,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // Title
                                  Text(
                                    task.title,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Description Label
                                  const Text(
                                    'DESCRIPTION',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Description
                                  Text(
                                    task.description ?? 'No description',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Focus Mode Warning
                                  if (task.focusMode == true)
                                    Column(
                                      children: [
                                        remainingTime > Duration.zero
                                            ? const Text("Focus Mode is active")
                                            : const Text("Focus Mode Completed"),
                                        Center(
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.red[100],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              children: [
                                                if (remainingTime > Duration.zero)
                                                  Text(
                                                    formatDuration(remainingTime),
                                                    style: const TextStyle(
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  )
                                                else
                                                  const Text(
                                                    "Time is over!",
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                  const Spacer(),

                                  // Date
                                  Text(
                                    dateText,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Bottom Buttons
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFE0B2),
                                    foregroundColor: const Color(0xFF5D4037),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  onPressed: () async {
                                    // รอให้หน้า Edit เสร็จแล้วอัพเดต countdown
                                    await Get.to(() => EditTaskPage(task: task));
                                    
                                    // หยุด timer เก่าและเริ่มใหม่หากจำเป็น
                                    timer?.cancel();
                                    _startCountdownIfNeeded();
                                  },
                                  child: const Text(
                                    'Edit Task',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFCDD2),
                                    foregroundColor: const Color(0xFFD32F2F),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  onPressed: () {
                                    _showDeleteConfirmDialog();
                                  },
                                  child: const Text(
                                    'delete task',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFC8E6C9),
                                    foregroundColor: const Color(0xFF2E7D32),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  onPressed: () {
                                    // TODO: Mark done logic
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'task done',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Task',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: Text(
            'Are you sure you want to delete "${currentTask.title}"? This action cannot be undone.',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
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
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Confirm',
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Task "${currentTask.title}" deleted successfully',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF4CAF50),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Failed to delete task. Please try again.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFD32F2F),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
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