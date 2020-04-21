import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tasks/models/task.dart';
import 'package:tasks/providers/tasks.dart';

class TaskItem extends StatefulWidget {
  final Task task;
  final bool showList;

  TaskItem({@required this.task, this.showList});

  @override
  _TaskItemState createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  bool _updatingStatus;
  bool _updatingImportant;

  @override
  void initState() {
    super.initState();
    _updatingStatus = false;
    _updatingImportant = false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 2.0),
      child: Dismissible(
        key: UniqueKey(),
        onDismissed: (direction) {
          Provider.of<Tasks>(
            context,
            listen: false,
          ).deleteTask(widget.task);
        },
        direction: DismissDirection.endToStart,
        child: _buildDismissibleContent(context),
        secondaryBackground: _buildDismissibleSecondaryBackground(),
        background: _buildDismissibleBackground(),
      ),
    );
  }

  Container _buildDismissibleContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(4.0),
        ),
        color: Colors.grey[850],
      ),
      child: Row(
        children: <Widget>[
          _buildTaskStatus(context),
          Expanded(
            child: _buildText(),
          ),
          _buildTaskImportant(context)
        ],
      ),
    );
  }

  Container _buildDismissibleSecondaryBackground() {
    return Container(
      padding: EdgeInsets.only(right: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            'Delete task',
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(width: 8.0),
          Icon(
            Icons.clear,
            color: Colors.white,
          ),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(4.0),
        ),
        color: Colors.red,
      ),
    );
  }

  Container _buildDismissibleBackground() {
    return Container(
      padding: EdgeInsets.only(left: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.clear,
            color: Colors.white,
          ),
          SizedBox(width: 8.0),
          Text(
            'Delete task',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(4.0),
        ),
        color: Colors.red,
      ),
    );
  }

  Widget _buildText() {
    return widget.showList && widget.task.list != null
        ? Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.task.title,
                style: TextStyle(
                  color: Colors.white70,
                  decoration: widget.task.status == 'DONE'
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              Text(
                widget.task.list != null ? widget.task.list.title : '',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10.0,
                ),
              )
            ],
          )
        : Text(
            widget.task.title,
            style: TextStyle(
              color: Colors.white70,
              decoration: widget.task.status == 'DONE'
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          );
  }

  Widget _buildTaskStatus(BuildContext context) {
    return _updatingStatus
        ? IconButton(
            icon: Icon(Icons.hourglass_empty, color: Colors.white24),
            onPressed: () {},
          )
        : IconButton(
            icon: widget.task.status == 'OPEN'
                ? Icon(Icons.radio_button_unchecked, color: Colors.white60)
                : Icon(Icons.check_circle,
                    color: Theme.of(context).primaryColor),
            onPressed: _onStatusUpdate,
          );
  }

  _onStatusUpdate() async {
    try {
      setState(() {
        _updatingStatus = true;
      });
      await Provider.of<Tasks>(context, listen: false)
          .updateTaskStatus(widget.task);
    } catch (e) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update status.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _updatingStatus = false;
      });
    }
  }

  IconButton _buildTaskImportant(BuildContext context) {
    return _updatingImportant
        ? IconButton(
            icon: Icon(Icons.hourglass_empty, color: Colors.white24),
            onPressed: () {},
          )
        : IconButton(
            icon: widget.task.important
                ? Icon(Icons.star, color: Theme.of(context).accentColor)
                : Icon(Icons.star_border, color: Colors.white60),
            onPressed: _onImportantUpdate,
          );
  }

  _onImportantUpdate() async {
    setState(() {
      _updatingImportant = true;
    });

    await Provider.of<Tasks>(context, listen: false)
        .updateTaskImportant(widget.task);

    _updatingImportant = false;
  }
}
