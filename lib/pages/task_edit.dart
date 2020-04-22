import 'package:flutter/material.dart';
import 'package:tasks/models/list.dart';
import 'package:tasks/models/task.dart';

class TaskEditPage extends StatelessWidget {
  final TaskList list;
  final Task task;

  TaskEditPage({@required this.list, @required this.task});

  @override
  Widget build(BuildContext context) {
    Text _buildAppBarTitle() {
      return Text(list != null ? list.title : 'Tasks');
    }

    return Scaffold(
      appBar: AppBar(
        title: _buildAppBarTitle(),
      ),
      body: Center(
        child: Text(task.title),
      ),
    );
  }
}
