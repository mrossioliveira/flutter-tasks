import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasks/models/list.dart';
import 'package:tasks/models/list_holder.dart';

import 'package:tasks/pages/task_list_detail.dart';

import 'package:tasks/providers/tasks.dart';
import 'package:tasks/widgets/task_list_item_counter.dart';

class TaskListItem extends StatelessWidget {
  final TaskList list;

  TaskListItem({@required this.list});

  @override
  Widget build(BuildContext context) {
    _buildLeadingIcon() {
      switch (list.id) {
        case ListHolder.IMPORTANT:
          return Icon(
            Icons.star,
            color: Theme.of(context).accentColor,
          );
        case ListHolder.TASKS:
          return Icon(
            Icons.done,
            color: Theme.of(context).primaryColor,
          );
        default:
          return Icon(
            Icons.list,
            color: Colors.grey[600],
          );
      }
    }

    return ListTile(
      title: Text(
        list.title,
        style: TextStyle(
          color: Colors.white70,
        ),
      ),
      trailing: TaskListItemCounter(list: list),
      leading: _buildLeadingIcon(),
      onTap: () {
        Provider.of<Tasks>(context, listen: false).selectList(
          list,
        );
        Navigator.of(context).push(
          new MaterialPageRoute(
            builder: (context) => TaskListDetailPage(),
          ),
        );
      },
    );
  }
}
