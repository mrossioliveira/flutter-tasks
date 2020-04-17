import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tasks/models/list.dart';
import 'package:tasks/models/task.dart';
import 'package:tasks/pages/task_list_detail.dart';
import 'package:tasks/providers/tasks.dart';

class TaskListWidget extends StatelessWidget {
  Center _buildLoading(BuildContext context) {
    return Center(
        child: CircularProgressIndicator(
      backgroundColor: Colors.grey[850],
      valueColor: new AlwaysStoppedAnimation<Color>(
        Theme.of(context).primaryColor,
      ),
    ));
  }

  Widget _buildTaskList(List<TaskList> taskLists) {
    return ListView.builder(
      itemCount: taskLists.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(
          taskLists[index].title,
          style: TextStyle(
            color: Colors.white70,
          ),
        ),
        leading: Icon(
          Icons.list,
          color: Theme.of(context).primaryColor,
        ),
        trailing: Text(
          _taskCountLabel(taskLists[index]
              .tasks
              .where((task) => task.status == 'OPEN')
              .toList()),
          style: TextStyle(color: Colors.grey[600]),
        ),
        onTap: () {
          Provider.of<Tasks>(context, listen: false)
              .selectList(taskLists[index]);
          Navigator.of(context).push(
            new MaterialPageRoute(
              builder: (context) => TaskListDetailPage(
                creating: false,
              ),
            ),
          );
        },
      ),
    );
  }

  String _taskCountLabel(List<Task> tasks) {
    return tasks.length > 0 ? tasks.length.toString() : '';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Tasks>(
      builder: (context, taskProvider, _) => Container(
        child: taskProvider.isLoading
            ? _buildLoading(context)
            : _buildTaskList(taskProvider.taskLists),
      ),
    );
  }
}
