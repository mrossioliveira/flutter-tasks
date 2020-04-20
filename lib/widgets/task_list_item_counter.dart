import 'package:flutter/material.dart';
import 'package:tasks/models/list.dart';

class TaskListItemCounter extends StatelessWidget {
  final TaskList list;

  TaskListItemCounter({@required this.list});

  @override
  Widget build(BuildContext context) {
    return Text(
      list.taskCounter > 0 ? list.taskCounter.toString() : '',
      style: TextStyle(color: Colors.grey[600]),
    );
  }
}
