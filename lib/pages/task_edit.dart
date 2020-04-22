import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasks/dto/update_task_dto.dart';

import 'package:tasks/providers/tasks.dart';

import 'package:tasks/models/list.dart';
import 'package:tasks/models/task.dart';
import 'package:tasks/services/debouncer.dart';

class TaskEditPage extends StatefulWidget {
  final TaskList list;
  final Task task;

  TaskEditPage({@required this.list, @required this.task});

  @override
  _TaskEditPageState createState() => _TaskEditPageState();
}

class _TaskEditPageState extends State<TaskEditPage> {
  bool _important;
  bool _done;

  @override
  void initState() {
    super.initState();
    _important = widget.task.important;
    _done = widget.task.status == 'DONE';
  }

  @override
  Widget build(BuildContext context) {
    final _titleController = TextEditingController(text: widget.task.title);
    final _notesController =
        TextEditingController(text: widget.task.description);

    final _titleFocusNode = FocusNode();
    final _notesFocusNode = FocusNode();

    final debouncer = new Debouncer(milliseconds: 500);

    Text _buildAppBarTitle() {
      return Text(widget.list != null ? widget.list.title : 'Tasks');
    }

    Widget _buildStatus() {
      return IconButton(
        icon: _done
            ? Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
              )
            : Icon(
                Icons.radio_button_unchecked,
                color: Colors.grey[600],
              ),
        onPressed: () {
          // optimistic update
          setState(() {
            _done = !_done;
          });
          try {
            Provider.of<Tasks>(context, listen: false)
                .updateTaskStatus(widget.task);
          } catch (e) {
            // rollback
            setState(() {
              _done = !_done;
            });
          }
        },
      );
    }

    Widget _buildImportant() {
      return IconButton(
        icon: _important
            ? Icon(
                Icons.star,
                color: Theme.of(context).accentColor,
              )
            : Icon(
                Icons.star_border,
                color: Colors.grey[600],
              ),
        onPressed: () {
          // optimistic update
          setState(() {
            _important = !_important;
          });
          try {
            Provider.of<Tasks>(context, listen: false)
                .updateTaskImportant(widget.task);
          } catch (e) {
            // rollback
            setState(() {
              _important = !_important;
            });
          }
        },
      );
    }

    _saveTask() async {
      if (_titleController.text.isNotEmpty) {
        Provider.of<Tasks>(
          context,
          listen: false,
        ).updateTask(
          widget.task.id,
          new UpdateTaskDto(
            title: _titleController.text.trim(),
            notes: _notesController.text.trim(),
          ),
        );
      }
    }

    Divider _buildDivider() {
      return Divider(
        indent: 16.0,
        endIndent: 16.0,
        color: Colors.grey.withOpacity(0.2),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: _buildAppBarTitle(),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 0.0),
            child: Row(
              children: <Widget>[
                _buildStatus(),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    focusNode: _titleFocusNode,
                    controller: _titleController,
                    onChanged: (_) {
                      debouncer.run(() => _saveTask());
                    },
                    decoration: InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                _buildImportant(),
              ],
            ),
          ),
          _buildDivider(),
          Container(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              controller: _notesController,
              focusNode: _notesFocusNode,
              decoration: InputDecoration(
                hintText: 'Notes',
                border: InputBorder.none,
              ),
              maxLines: 12,
              textInputAction: TextInputAction.newline,
              onChanged: (_) {
                debouncer.run(() => _saveTask());
              },
            ),
          ),
          _buildDivider(),
        ],
      ),
    );
  }
}
