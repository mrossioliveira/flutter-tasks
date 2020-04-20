import 'package:flutter/material.dart';

class TaskList {
  final int id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskList({
    this.id,
    @required this.title,
    this.createdAt,
    this.updatedAt,
  });

  factory TaskList.fromJson(Map<String, dynamic> json) {
    print(json);
    return TaskList(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
