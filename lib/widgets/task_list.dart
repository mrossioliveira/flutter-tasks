import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'package:tasks/models/list.dart';
import 'package:tasks/providers/tasks.dart';
import 'package:tasks/widgets/task_list_item.dart';

class TaskListWidget extends StatelessWidget {
  Widget _buildShimerLoading(BuildContext context) {
    return ListView.builder(
      itemCount: 2,
      itemBuilder: (context, index) => Shimmer.fromColors(
        child: ListTile(
          title: Container(
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.all(
                Radius.circular(2.0),
              ),
            ),
          ),
        ),
        baseColor: Colors.grey[850],
        highlightColor: Colors.grey[800],
      ),
    );
  }

  Widget _buildTaskList(List<TaskList> taskLists) {
    return ListView.builder(
      itemCount: taskLists.length,
      itemBuilder: (context, index) => index == 2
          ? Container(
              child: Column(
              children: <Widget>[
                Divider(
                  indent: 16.0,
                  endIndent: 16.0,
                ),
                TaskListItem(list: taskLists[index]),
              ],
            ))
          : TaskListItem(list: taskLists[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Tasks>(
      builder: (context, taskProvider, _) => Container(
        child: taskProvider.isLoading
            ? _buildShimerLoading(context)
            : _buildTaskList(taskProvider.taskLists),
      ),
    );
  }
}
