// todo_item.dart
import 'package:flutter/material.dart';

class TodoItem {
  int? id;
  String title;
  String chip;
  DateTime dueDate;
  bool done;
  Color chipColor;
  bool isHabit;

  TodoItem({
    this.id,
    required this.title,
    required this.chip,
    required this.dueDate,
    this.done = false,
    required this.chipColor,
    this.isHabit = false,
  });

  // Convert dari Map (row database) ke object
  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      chip: map['chip'] as String,
      dueDate: DateTime.parse(map['dueDate'] as String),
      done: (map['done'] as int) == 1,
      chipColor: Color(map['chipColor'] as int),
      isHabit: (map['isHabit'] as int) == 1,
    );
  }

  // Convert object ke Map untuk disimpan ke database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'chip': chip,
      'dueDate': dueDate.toIso8601String(),
      'done': done ? 1 : 0,
      'chipColor': chipColor.value,
      'isHabit': isHabit ? 1 : 0,
    };
  }
}
