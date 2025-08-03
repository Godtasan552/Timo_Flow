import 'package:flutter/material.dart';

// ประกาศคลาส User สำหรับเก็บข้อมูลผู้ใช้
class User {
  final String id;
  final String email;
  final String username;
  final String password;
  final String firstName;
  final String lastName;
  final String? profileImage;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.profileImage,
  });

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'username': username,
    'password': password,
    'firstName': firstName,
    'lastName': lastName,
    'profileImage': profileImage,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    email: json['email'],
    username: json['username'],
    password: json['password'],
    firstName: json['firstName'],
    lastName: json['lastName'],
    profileImage: json['profileImage'],
  );
}