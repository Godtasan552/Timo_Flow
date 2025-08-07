import 'package:flutter/material.dart';

enum TaskType { even, goal, birthday }

class Task {
  String id;
  String userId;
  String title;
  String? description;
  String category;
  DateTime date;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool isAllDay;
  List<int> notifyBefore;
  bool focusMode;
  bool isDone;
  DateTime? completedDate;
  TaskType type;

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
    this.completedDate,
    required this.type,
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
        notifyBefore: (json['notifyBefore'] as List?)?.map((e) => e as int).toList() ?? [],
        focusMode: json['focusMode'] ?? false,
        isDone: json['isDone'] ?? false,
        completedDate: json['completedDate'] != null
            ? DateTime.parse(json['completedDate'])
            : null,
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
        'startTime': startTime != null ? '${startTime!.hour}:${startTime!.minute}' : null,
        'endTime': endTime != null ? '${endTime!.hour}:${endTime!.minute}' : null,
        'isAllDay': isAllDay,
        'notifyBefore': notifyBefore,
        'focusMode': focusMode,
        'isDone': isDone,
        'completedDate': completedDate?.toIso8601String(),
        'type': type.name,
      };
}
