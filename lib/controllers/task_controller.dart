import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/tasks_model.dart';
import '../services/storage_service_mobile.dart';
import '../controllers/auth_controller.dart';

class TaskController extends GetxController {
  RxList<Task> tasks = <Task>[].obs;
  final authController = Get.find<AuthController>();
  String? userId;

  @override
  void onInit() {
    super.onInit();
    userId = authController.currentUser.value?.id;
    if (userId != null) {
      loadTasksForUser(userId!);
    }
  }

  Future<void> loadTasksForUser(String userId) async {
    final allTasks = await StorageService.loadTasks();
    await _removeExpiredCompletedTasks(allTasks, userId); // ลบ task goal ที่เสร็จเกิน 7 วัน
    final updatedTasks = await StorageService.loadTasks(); // โหลดใหม่หลังลบ
    tasks.value = updatedTasks.where((t) => t.userId == userId).toList();
  }

  Future<void> _removeExpiredCompletedTasks(List<Task> allTasks, String userId) async {
    final now = DateTime.now();
    final tasksToRemove = <Task>[];

    for (var task in allTasks) {
      if (task.userId == userId &&
          task.isDone &&
          task.completedDate != null &&
          task.type == TaskType.goal) {
        final daysSinceCompleted = now.difference(task.completedDate!).inDays;
        if (daysSinceCompleted >= 7) {
          tasksToRemove.add(task);
        }
      }
    }

    if (tasksToRemove.isNotEmpty) {
      for (var taskToRemove in tasksToRemove) {
        allTasks.removeWhere((t) => t.id == taskToRemove.id);
      }
      await StorageService.saveTasks(allTasks);
    }
  }

  Future<void> addTask(Task task) async {
    final allTasks = await StorageService.loadTasks();
    allTasks.add(task);
    await StorageService.saveTasks(allTasks);
    await loadTasksForUser(task.userId);
  }

  Future<void> updateTask(Task updatedTask) async {
    final allTasks = await StorageService.loadTasks();
    final idx = allTasks.indexWhere((t) => t.id == updatedTask.id);
    if (idx != -1) {
      allTasks[idx] = updatedTask;
      await StorageService.saveTasks(allTasks);
      await loadTasksForUser(updatedTask.userId);
    }
  }

  Future<void> deleteTask(String taskId, String userId) async {
    final allTasks = await StorageService.loadTasks();
    allTasks.removeWhere((t) => t.id == taskId);
    await StorageService.saveTasks(allTasks);
    await loadTasksForUser(userId);
  }

  void deleteTaskById(String taskId) async {
    await StorageService.deleteTask(taskId);
    tasks.removeWhere((task) => task.id == taskId); // อัปเดต RxList ทันที
  }

  List<Task> searchTasks(String query) => tasks
      .where((t) =>
          t.title.toLowerCase().contains(query.toLowerCase()) ||
          (t.description?.toLowerCase().contains(query.toLowerCase()) ?? false))
      .toList();

  List<Task> filterByCategory(String category) =>
      tasks.where((t) => t.category == category).toList();

  List<Task> filterByDate(DateTime date) => tasks
      .where((t) =>
          t.date.year == date.year &&
          t.date.month == date.month &&
          t.date.day == date.day)
      .toList();
}
