import 'package:flutter/material.dart';
import '../model/category_model.dart';

enum TaskType { even, work, birthday }

class Task {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String category;
  final DateTime date;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final bool isAllDay;
  final List<int> notifyBefore;
  final bool focusMode;
  final bool isDone;
  final TaskType type; // เพิ่มตรงนี้

  Task({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.category,
    required this.date,
    this.startTime,
    this.endTime,
    this.isAllDay = false,
    this.notifyBefore = const [],
    this.focusMode = false,
    this.isDone = false,
    required this.type, // เพิ่มตรงนี้
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    userId: json['userId'],
    title: json['title'],
    description: json['description'],
    category: json['category'],
    date: DateTime.parse(json['date']),
    startTime: json['startTime'] != null
        ? TimeOfDay(
            hour: int.parse(json['startTime'].split(':')[0]),
            minute: int.parse(json['startTime'].split(':')[1]),
          )
        : null,
    endTime: json['endTime'] != null
        ? TimeOfDay(
            hour: int.parse(json['endTime'].split(':')[0]),
            minute: int.parse(json['endTime'].split(':')[1]),
          )
        : null,
    isAllDay: json['isAllDay'] ?? false,
    notifyBefore:
        (json['notifyBefore'] as List?)?.map((e) => e as int).toList() ?? [],
    focusMode: json['focusMode'] ?? false,
    isDone: json['isDone'] ?? false,
    type: TaskType.values.firstWhere(
      (e) => e.toString() == 'TaskType.${json['type']}',
      orElse: () => TaskType.even,
    ),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'description': description,
    'category': category,
    'date': date.toIso8601String(),
    'startTime': startTime != null
        ? '${startTime!.hour}:${startTime!.minute}'
        : null,
    'endTime': endTime != null ? '${endTime!.hour}:${endTime!.minute}' : null,
    'isAllDay': isAllDay,
    'notifyBefore': notifyBefore,
    'focusMode': focusMode,
    'isDone': isDone,
    'type': type.name, // บันทึกเป็น even, work, birthday
  };
}
