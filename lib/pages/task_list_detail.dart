import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tasks/models/list.dart';
import 'package:tasks/models/list_type.dart';
import 'package:tasks/models/task.dart';
import 'package:tasks/providers/tasks.dart';
import 'package:tasks/styles.dart';
import 'package:tasks/widgets/empty_list_art.dart';
import 'package:tasks/widgets/task_item.dart';

class TaskListDetailPage extends StatelessWidget {
  TaskListDetailPage();

  _buildTaskList(TaskList list, List<Task> tasks, bool showList) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return TaskItem(
          list: list,
          task: tasks[index],
          showList: showList,
        );
      },
    );
  }

  bool _hasTasks(TaskList taskList) {
    if (taskList.taskCounter == 0) {
      return false;
    }
    return true;
  }

  _showTasks(BuildContext context) {
    return Consumer<Tasks>(
      builder: (context, taskProvider, _) => Container(
        padding: EdgeInsets.all(0),
        margin: EdgeInsets.all(0),
        child: _hasTasks(taskProvider.selectedList)
            ? _buildTaskList(
                taskProvider.selectedList,
                taskProvider.tasks,
                taskProvider.selectedList.id == ListType.IMPORTANT,
              )
            : EmptyList(),
      ),
    );
  }

  _onRefresh(BuildContext context) async {
    Provider.of<Tasks>(context, listen: false).refreshSelectedList();
  }

  @override
  Widget build(BuildContext context) {
    final _listInputController = TextEditingController();
    final _taskInputController = TextEditingController();

    _onRename() {
      final taskProvider = Provider.of<Tasks>(context, listen: false);
      _listInputController.text = taskProvider.selectedList.title;
      if (taskProvider.selectedList.id > 0) {
        showDialog(
          barrierDismissible: false,
          useRootNavigator: true,
          context: context,
          child: new SimpleDialog(
            contentPadding: EdgeInsets.all(0),
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: _listInputController,
                      autofocus: true,
                      decoration: InputDecoration(hintText: 'Enter list title'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        FlatButton(
                          child: Text(
                            'Cancel',
                            style: TEXT_BODY_LIGHT,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        FlatButton(
                          color: Theme.of(context).primaryColor,
                          child: Text(
                            'Save',
                            style: TEXT_BODY_WHITE,
                          ),
                          onPressed: () async {
                            await Provider.of<Tasks>(
                              context,
                              listen: false,
                            ).updateListTitle(_listInputController.text);

                            // close popup
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        );
      }
    }

    _onDelete() {
      showDialog(
        barrierDismissible: false,
        useRootNavigator: true,
        context: context,
        child: new SimpleDialog(
          contentPadding: EdgeInsets.all(0),
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Are you sure?',
                    style: TEXT_DIALOG_TITLE,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'All tasks associated with this list will be permanently deleted.',
                    style: TEXT_BODY_LIGHT,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'This action cannot be undone.',
                    style: TEXT_BODY_RED,
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FlatButton(
                        child: Text(
                          'Cancel',
                          style: TEXT_BODY_LIGHT,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        color: Colors.red,
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await Provider.of<Tasks>(
                            context,
                            listen: false,
                          ).deleteList();

                          // send to home page
                          Navigator.popUntil(
                              context, (Route<dynamic> route) => route.isFirst);
                        },
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      );
    }

    _onToggleCompleted() {
      Provider.of<Tasks>(
        context,
        listen: false,
      ).toggleShowCompleted();
    }

    _getTitleColor(BuildContext context, TaskList list) {
      switch (list.id) {
        case ListType.IMPORTANT:
          return Theme.of(context).accentColor;
        case ListType.TASKS:
          return Theme.of(context).primaryColor;
        default:
          return Colors.grey[400];
      }
    }

    _onTaskSubmit(String title, bool pop) {
      Provider.of<Tasks>(
        context,
        listen: false,
      ).addTask(
        new Task(
          id: 10,
          title: title,
          description: '',
          important: false,
        ),
      );
      _taskInputController.clear();

      if (pop) {
        Navigator.of(context).pop();
      }
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          showModalBottomSheet(
            isDismissible: true,
            useRootNavigator: true,
            isScrollControlled: true,
            context: context,
            builder: (context) {
              return Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Padding(
                  padding: Theme.of(context).platform == TargetPlatform.iOS
                      ? EdgeInsets.only(
                          bottom: 24.0,
                          top: 8.0,
                          left: 8.0,
                          right: 8.0,
                        )
                      : EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          textInputAction: TextInputAction.send,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          controller: _taskInputController,
                          decoration: InputDecoration(
                            hasFloatingPlaceholder: false,
                            hintText: 'Add task',
                          ),
                          autofocus: true,
                          onSubmitted: (value) {
                            _onTaskSubmit(value.trim(), true);
                          },
                        ),
                      ),
                      IconButton(
                        color: Colors.blue,
                        icon: Icon(Icons.arrow_upward),
                        onPressed: () {
                          _onTaskSubmit(
                            _taskInputController.text.trim(),
                            false,
                          );
                        },
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      appBar: Consumer<Tasks>(
        builder: (context, taskProvider, _) => AppBar(
          backgroundColor: Colors.transparent,
          title: GestureDetector(
            onTap: _onRename,
            onDoubleTap: () {
              Provider.of<Tasks>(
                context,
                listen: false,
              ).toggleShowCompleted();
            },
            child: Text(
              taskProvider.selectedList != null
                  ? taskProvider.selectedList.title
                  : 'Untitled list',
              style: TextStyle(
                color: _getTitleColor(context, taskProvider.selectedList),
              ),
            ),
          ),
          actions: <Widget>[
            PopupMenuButton<MenuOption>(
              onSelected: (MenuOption option) {
                switch (option.code) {
                  case 'RENAME':
                    _onRename();
                    break;
                  case 'TOGGLE_COMPLETED':
                    _onToggleCompleted();
                    break;
                  case 'DELETE':
                    _onDelete();
                    break;
                }
              },
              itemBuilder: (context) {
                List<MenuOption> options = <MenuOption>[
                  MenuOption(
                    code: 'RENAME',
                    title: 'Rename list',
                    icon: Icons.edit,
                  ),
                  MenuOption(
                    code: 'TOGGLE_COMPLETED',
                    title: taskProvider.showCompleted
                        ? 'Hide completed'
                        : 'Show Completed',
                    icon: taskProvider.showCompleted
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  MenuOption(
                    code: 'DELETE',
                    title: 'Delete list',
                    icon: Icons.delete_forever,
                  ),
                ];

                if (taskProvider.selectedList.id < 0) {
                  options = options
                      .where((option) => option.code == 'TOGGLE_COMPLETED')
                      .toList();
                }

                return options.map((MenuOption option) {
                  return PopupMenuItem<MenuOption>(
                    value: option,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          option.icon,
                          color: Colors.grey[400],
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        Text(option.title)
                      ],
                    ),
                  );
                }).toList();
              },
            )
          ],
        ),
      ).build(context),
      body: RefreshIndicator(
        child: _showTasks(context),
        onRefresh: () => _onRefresh(context),
      ),
    );
  }
}

class MenuOption {
  const MenuOption({this.code, this.title, this.icon});

  final String code;
  final String title;
  final IconData icon;
}
