import 'package:flutter/material.dart';

// ประกาศคลาส User สำหรับเก็บข้อมูลผู้ใช้
class User {
  final String id;
  final String email;
  final String username;
  final String password;
  final String? profileImage;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.password,

    this.profileImage,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'username': username,
    'password': password,
    'profileImage': profileImage,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    email: json['email'],
    username: json['username'],
    password: json['password'],
    profileImage: json['profileImage'],
  );
}