import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html; // ใช้ได้เฉพาะ web

import '../model/user_model.dart';

class UniversalStorageService {
  static const _userKey = 'users_data';

  static Future<List<User>> loadUsers() async {
    final jsonString = await _read(_userKey);
    if (jsonString == null) return [];
    final List<dynamic> data = jsonDecode(jsonString);
    return data.map((e) => User.fromJson(e)).toList();
  }

  static Future<void> saveUsers(List<User> users) async {
    final jsonString = jsonEncode(users.map((e) => e.toJson()).toList());
    await _write(_userKey, jsonString);
  }

  static Future<String?> _read(String key) async {
    if (kIsWeb) {
      return html.window.localStorage[key];
    } else {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }
  }

  static Future<void> _write(String key, String value) async {
    if (kIsWeb) {
      html.window.localStorage[key] = value;
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    }
  }
}
