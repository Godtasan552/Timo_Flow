import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../model/user_model.dart';
import '../model/tasks_model.dart';

class StorageService {
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

  static Future<List<Task>> loadTasks() async {
    final file = await _getFile('tasks.json');
    if (!await file.exists()) return [];
    final data = jsonDecode(await file.readAsString());
    return (data as List).map((e) => Task.fromJson(e)).toList();
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    final file = await _getFile('tasks.json');
    await file.writeAsString(jsonEncode(tasks.map((e) => e.toJson()).toList()));
  }
}