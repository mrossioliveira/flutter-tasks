import 'package:flutter/material.dart';
import 'package:tasks/models/list.dart';
import 'package:tasks/models/task.dart';

class TaskListItemCounter extends StatelessWidget {
  final TaskList list;

  TaskListItemCounter({@required this.list});

  @override
  Widget build(BuildContext context) {
    // FIXME: Load counter
    return Text(
      _taskCountLabel([]),
      style: TextStyle(color: Colors.grey[600]),
    );
  }

  String _taskCountLabel(List<Task> tasks) {
    return tasks.length > 0 ? tasks.length.toString() : '';
  }
}
