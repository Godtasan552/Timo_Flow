import 'dart:convert';
import 'dart:html' as html;

import '../model/user_model.dart';
import '../model/tasks_model.dart';

class StorageService {
  static Future<List<User>> loadUsers() async {
    final data = html.window.localStorage['users'];
    if (data == null) return [];
    final list = jsonDecode(data);
    return (list as List).map((e) => User.fromJson(e)).toList();
  }

  static Future<void> saveUsers(List<User> users) async {
    final data = jsonEncode(users.map((e) => e.toJson()).toList());
    html.window.localStorage['users'] = data;
  }

  static Future<List<Task>> loadTasks() async {
    final data = html.window.localStorage['tasks'];
    if (data == null) return [];
    final list = jsonDecode(data);
    return (list as List).map((e) => Task.fromJson(e)).toList();
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    final data = jsonEncode(tasks.map((e) => e.toJson()).toList());
    html.window.localStorage['tasks'] = data;
  }
}
