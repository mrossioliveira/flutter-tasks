import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasks/models/list.dart';

import 'package:tasks/pages/task_list_detail.dart';

import 'package:tasks/providers/tasks.dart';
import 'package:tasks/widgets/task_list_item_counter.dart';

class TaskListItem extends StatelessWidget {
  final TaskList list;

  TaskListItem({@required this.list});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        list.title,
        style: TextStyle(
          color: Colors.white70,
        ),
      ),
      trailing: TaskListItemCounter(list: list),
      leading: Icon(
        list.id != -1 ? Icons.list : Icons.star,
        color: list.id != -1
            ? Theme.of(context).primaryColor
            : Theme.of(context).accentColor,
      ),
      onTap: () {
        Provider.of<Tasks>(context, listen: false).selectList(
          list,
        );
        Navigator.of(context).push(
          new MaterialPageRoute(
            builder: (context) => TaskListDetailPage(
              creating: false,
            ),
          ),
        );
      },
    );
  }
}
