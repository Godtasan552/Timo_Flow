import 'package:flutter/material.dart';

// ประกาศคลาส User สำหรับเก็บข้อมูลผู้ใช้
class User{
  final String id;
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? profileImage;

// ตัวสร้างแบบ named parameters ที่บังคับใส่ค่า required ทุกตัว เพื่อให้สร้าง User ได้ครบข้อมูลทุกฟิล
  User({
    required this.id,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.profileImage,
  });
  
  // ฟังก์ชันนี้แปลงข้อมูลจาก JSON เป็น User object
  //factory User dot fromJson รับพารามิเตอร์ json ที่เป็น Map แล้วสร้าง User ใหม่โดยดึงค่า id, email, password, firstName, lastName จาก json มาใส่ใน User
  
  factory User.fromjson(Map<String, dynamic> json) => User(
    id: json['id'],
    email: json['email'],
    password: json['password'],
    firstName: json['firstName'],
    lastName: json['lastName'],
    profileImage: json['profileImage'], // อาจจะเป็น null ถ้าไม่มีข้อมูล
  );

    String get fullName => '$firstName $lastName'; //ชื่อเต็ม

  //ฟังก์ชัน toJson แปลง User เป็น JSON โดยคืนค่าเป็น map ของชื่อฟิลด์กับค่าภายในออบเจ็กต์
  Map<String, dynamic> tojson() => {
    'id': id,
    'email': email,
    'password': password,
    'firstName': firstName,
    'lastName': lastName,
    'profileImage': profileImage, // อาจจะเป็น null ถ้าไม่มีข้อมูล
  };
}