import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../model/user_model.dart';
import '../model/tasks_model.dart';

class StorageService {
  static const String _tasksFileName = 'tasks.json';
  static const String _categoriesFileName = 'categories.json';
  static Future<File> _getFile(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$filename');
  }

  static Future<List<User>> loadUsers() async {
    final file = await _getFile('users.json');
    if (!await file.exists()) return [];
    final data = jsonDecode(await file.readAsString());
    return (data as List).map((e) => User.fromJson(e)).toList();
  }

  static Future<void> saveUsers(List<User> users) async {
    final file = await _getFile('users.json');
    await file.writeAsString(jsonEncode(users.map((e) => e.toJson()).toList()));
  }

  // Removed duplicate loadTasks method to resolve naming conflict.

  static Future<void> saveTasks(List<Task> tasks) async {
    final file = await _getFile('tasks.json');
    await file.writeAsString(jsonEncode(tasks.map((e) => e.toJson()).toList()));
  }

  // create task
  static Future<List<String>> loadCategoriesSimple() async {
    final file = await _getFile('categories.json');
    if (!await file.exists()) return [];
    final data = jsonDecode(await file.readAsString());
    return List<String>.from(data);
  }

  static Future<void> saveCategoriesSimple(List<String> categories) async {
    final file = await _getFile('categories.json');
    await file.writeAsString(jsonEncode(categories));
  }

  static const List<String> _defaultCategories = [
    'งานส่วนตัว',
    'งานที่ทำ',
    'การศึกษา',
    'สุขภาพ',
    'ครอบครัว',
    'เพื่อน',
    'งานบ้าน',
    'ช้อปปิ้ง',
  ];

  // Get application documents directory
  static Future<Directory> get _documentsDirectory async {
    return await getApplicationDocumentsDirectory();
  }

  // Get tasks file
  static Future<File> get _tasksFile async {
    final directory = await _documentsDirectory;
    return File('${directory.path}/$_tasksFileName');
  }

  // Get categories file
  static Future<File> get _categoriesFile async {
    final directory = await _documentsDirectory;
    return File('${directory.path}/$_categoriesFileName');
  }

  // Load tasks from JSON file
  static Future<List<Task>> loadTasks() async {
    try {
      final file = await _tasksFile;

      if (!await file.exists()) {
        return [];
      }

      final content = await file.readAsString();
      if (content.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(content);
      return jsonList.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      print('Error loading tasks: $e');
      return [];
    }
  }

  // Save tasks to JSON file
  static Future<void> saveTasksToFile(List<Task> tasks) async {
    try {
      final file = await _tasksFile;
      final jsonList = tasks.map((task) => task.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving tasks: $e');
      throw Exception('Failed to save tasks: $e');
    }
  }

  // Load categories from JSON file
  static Future<List<String>> loadCategories() async {
    try {
      final file = await _categoriesFile;

      if (!await file.exists()) {
        // Create default categories file if it doesn't exist
        await saveCategories(_defaultCategories);
        return List.from(_defaultCategories);
      }

      final content = await file.readAsString();
      if (content.isEmpty) {
        await saveCategories(_defaultCategories);
        return List.from(_defaultCategories);
      }

      final List<dynamic> jsonList = jsonDecode(content);
      return jsonList.map((category) => category.toString()).toList();
    } catch (e) {
      print('Error loading categories: $e');
      // Return default categories if there's an error
      return List.from(_defaultCategories);
    }
  }

  // Save categories to JSON file
  static Future<void> saveCategories(List<String> categories) async {
    try {
      final file = await _categoriesFile;
      final jsonString = jsonEncode(categories);
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving categories: $e');
      throw Exception('Failed to save categories: $e');
    }
  }

  // Add a new category
  static Future<void> addCategory(String category) async {
    try {
      final categories = await loadCategories();
      if (!categories.contains(category)) {
        categories.add(category);
        await saveCategories(categories);
      }
    } catch (e) {
      print('Error adding category: $e');
      throw Exception('Failed to add category: $e');
    }
  }

  // Remove a category
  static Future<void> removeCategory(String category) async {
    try {
      final categories = await loadCategories();
      categories.remove(category);
      await saveCategories(categories);
    } catch (e) {
      print('Error removing category: $e');
      throw Exception('Failed to remove category: $e');
    }
  }

  // Get tasks by category
  static Future<List<Task>> getTasksByCategory(String category) async {
    try {
      final tasks = await loadTasks();
      return tasks.where((task) => task.category == category).toList();
    } catch (e) {
      print('Error filtering tasks by category: $e');
      return [];
    }
  }

  // Get tasks by date
  static Future<List<Task>> getTasksByDate(DateTime date) async {
    try {
      final tasks = await loadTasks();
      return tasks.where((task) {
        return task.date.year == date.year &&
            task.date.month == date.month &&
            task.date.day == date.day;
      }).toList();
    } catch (e) {
      print('Error filtering tasks by date: $e');
      return [];
    }
  }

  // Get tasks by type
  static Future<List<Task>> getTasksByType(TaskType type) async {
    try {
      final tasks = await loadTasks();
      return tasks.where((task) => task.type == type).toList();
    } catch (e) {
      print('Error filtering tasks by type: $e');
      return [];
    }
  }

  // Update a task
  static Future<void> updateTask(Task updatedTask) async {
    try {
      final tasks = await loadTasks();
      final index = tasks.indexWhere((task) => task.id == updatedTask.id);

      if (index != -1) {
        tasks[index] = updatedTask;
        await saveTasksToFile(tasks);
      } else {
        throw Exception('Task not found');
      }
    } catch (e) {
      print('Error updating task: $e');
      throw Exception('Failed to update task: $e');
    }
  }

  // Delete a task
  static Future<void> deleteTask(String taskId) async {
    try {
      final tasks = await loadTasks();
      tasks.removeWhere((task) => task.id == taskId);
      await saveTasks(tasks);
    } catch (e) {
      print('Error deleting task: $e');
      throw Exception('Failed to delete task: $e');
    }
  }

  // Mark task as done/undone
  static Future<void> toggleTaskStatus(String taskId) async {
    try {
      final tasks = await loadTasks();
      final index = tasks.indexWhere((task) => task.id == taskId);

      if (index != -1) {
        final task = tasks[index];
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
          isDone: !task.isDone, // Toggle the status
          type: task.type,
        );

        tasks[index] = updatedTask;
        await saveTasks(tasks);
      } else {
        throw Exception('Task not found');
      }
    } catch (e) {
      print('Error toggling task status: $e');
      throw Exception('Failed to toggle task status: $e');
    }
  }

  // Get upcoming tasks (next 7 days)
  static Future<List<Task>> getUpcomingTasks() async {
    try {
      final tasks = await loadTasks();
      final now = DateTime.now();
      final nextWeek = now.add(const Duration(days: 7));

      return tasks.where((task) {
        return task.date.isAfter(now.subtract(const Duration(days: 1))) &&
            task.date.isBefore(nextWeek) &&
            !task.isDone;
      }).toList()..sort((a, b) => a.date.compareTo(b.date));
    } catch (e) {
      print('Error getting upcoming tasks: $e');
      return [];
    }
  }

  // Get overdue tasks
  static Future<List<Task>> getOverdueTasks() async {
    try {
      final tasks = await loadTasks();
      final now = DateTime.now();

      return tasks.where((task) {
          return task.date.isBefore(now) && !task.isDone;
        }).toList()
        ..sort((a, b) => b.date.compareTo(a.date)); // Most recent first
    } catch (e) {
      print('Error getting overdue tasks: $e');
      return [];
    }
  }

  // Clear all data (for testing or reset)
  static Future<void> clearAllData() async {
    try {
      final tasksFile = await _tasksFile;
      final categoriesFile = await _categoriesFile;

      if (await tasksFile.exists()) {
        await tasksFile.delete();
      }

      if (await categoriesFile.exists()) {
        await categoriesFile.delete();
      }
    } catch (e) {
      print('Error clearing data: $e');
      throw Exception('Failed to clear data: $e');
    }
  }

  // Export tasks to JSON string (for backup)
  static Future<String> exportTasks() async {
    try {
      final tasks = await loadTasks();
      final categories = await loadCategories();

      final exportData = {
        'tasks': tasks.map((task) => task.toJson()).toList(),
        'categories': categories,
        'exportDate': DateTime.now().toIso8601String(),
      };

      return jsonEncode(exportData);
    } catch (e) {
      print('Error exporting tasks: $e');
      throw Exception('Failed to export tasks: $e');
    }
  }

  // Import tasks from JSON string (for restore)
  static Future<void> importTasks(String jsonString) async {
    try {
      final Map<String, dynamic> importData = jsonDecode(jsonString);

      if (importData.containsKey('tasks')) {
        final List<dynamic> tasksJson = importData['tasks'];
        final tasks = tasksJson.map((json) => Task.fromJson(json)).toList();
        await saveTasks(tasks);
      }

      if (importData.containsKey('categories')) {
        final List<dynamic> categoriesJson = importData['categories'];
        final categories = categoriesJson.map((cat) => cat.toString()).toList();
        await saveCategories(categories);
      }
    } catch (e) {
      print('Error importing tasks: $e');
      throw Exception('Failed to import tasks: $e');
    }
  }
}
