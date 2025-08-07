import 'package:flutter/foundation.dart'; // สำหรับ kIsWeb
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:io';
import 'dart:convert';
import '../model/user_model.dart';
import '../model/tasks_model.dart';

class StorageService {
  static Future<void> deleteTask(String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('tasks');
    if (data == null) return;
    final list = jsonDecode(data);
    List<Task> tasks = (list as List).map((e) => Task.fromJson(e)).toList();
    tasks.removeWhere((task) => task.id == taskId);
    final newData = jsonEncode(tasks.map((e) => e.toJson()).toList());
    await prefs.setString('tasks', newData);
  }

  static Future<List<User>> loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('users');
    if (data == null) return [];
    final list = jsonDecode(data);
    return (list as List).map((e) => User.fromJson(e)).toList();
  }

  static Future<void> saveUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(users.map((e) => e.toJson()).toList());
    await prefs.setString('users', data);
  }

  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('tasks');
    if (data == null) return [];
    final list = jsonDecode(data);
    return (list as List).map((e) => Task.fromJson(e)).toList();
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(tasks.map((e) => e.toJson()).toList());
    await prefs.setString('tasks', data);
  }
}
