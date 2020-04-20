import 'package:flutter/material.dart';

import 'package:tasks/models/task.dart';

class TaskList {
  final int id;
  final String title;
  final List<Task> tasks;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskList({
    this.id,
    @required this.title,
    this.tasks,
    this.createdAt,
    this.updatedAt,
  });

  factory TaskList.fromJson(Map<String, dynamic> json) {
    final jsonTasks = json['tasks'];
    final List<Task> tasks =
        jsonTasks.map<Task>((task) => Task.fromJson(task)).toList();

    return TaskList(
      id: json['id'],
      title: json['title'],
      tasks: tasks,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
