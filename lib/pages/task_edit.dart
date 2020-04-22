import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasks/dto/update_task_dto.dart';

import 'package:tasks/providers/tasks.dart';

import 'package:tasks/models/list.dart';
import 'package:tasks/models/task.dart';
import 'package:tasks/services/debouncer.dart';

class TaskEditPage extends StatelessWidget {
  final TaskList list;
  final Task task;

  TaskEditPage({@required this.list, @required this.task});

  @override
  Widget build(BuildContext context) {
    final _titleController = TextEditingController(text: task.title);
    final _notesController = TextEditingController(text: task.description);

    final _titleFocusNode = FocusNode();
    final _notesFocusNode = FocusNode();

    final debouncer = new Debouncer(milliseconds: 500);

    Text _buildAppBarTitle() {
      return Text(list != null ? list.title : 'Tasks');
    }

    Widget _buildStatus() {
      return Icon(Icons.check_circle);
    }

    Widget _buildImportant() {
      return Icon(Icons.star_border);
    }

    _saveTask() async {
      Provider.of<Tasks>(
        context,
        listen: false,
      ).updateTask(
        task.id,
        new UpdateTaskDto(
          title: _titleController.text,
          notes: _notesController.text,
        ),
      );
      return true;
    }

    return WillPopScope(
      onWillPop: _saveTask,
      child: Scaffold(
        appBar: AppBar(
          title: _buildAppBarTitle(),
        ),
        body: ListView(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  _buildStatus(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        textInputAction: TextInputAction.next,
                        focusNode: _titleFocusNode,
                        controller: _titleController,
                        onChanged: (_) {
                          debouncer.run(() => print(_saveTask()));
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  _buildImportant(),
                ],
              ),
            ),
            Divider(
              color: Colors.black,
            ),
            Container(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: _notesController,
                focusNode: _notesFocusNode,
                decoration: InputDecoration(
                  hintText: 'Notes',
                ),
                maxLines: 6,
                textInputAction: TextInputAction.newline,
                onChanged: (_) {
                  debouncer.run(() => print(_saveTask()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
