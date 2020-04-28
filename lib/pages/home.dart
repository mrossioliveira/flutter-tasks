import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tasks/pages/task_list_detail.dart';
import 'package:tasks/pages/settings.dart';
import 'package:tasks/styles.dart';
import 'package:tasks/widgets/task_list.dart';
import 'package:tasks/providers/auth.dart';
import 'package:tasks/providers/tasks.dart';

class HomePage extends StatelessWidget {
  final _listInputController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    _onListSubmit(String title) async {
      if (title.isNotEmpty) {
        try {
          await Provider.of<Tasks>(
            context,
            listen: false,
          ).addList(title);

          Navigator.of(context).pop();
          _listInputController.clear();

          Navigator.of(context).push(
            new MaterialPageRoute(
              builder: (context) => TaskListDetailPage(),
            ),
          );
        } catch (e) {
          Navigator.of(context).pop();
          showDialog(
            context: context,
            child: new AlertDialog(
              content: Text('Failed'),
            ),
          );
        }
      }
    }

    final auth = Provider.of<Auth>(context);

    _onUserTap() {
      Navigator.of(context).push(
        new MaterialPageRoute(
          builder: (context) => SettingsPage(),
        ),
      );
    }

    _listInputController.addListener(() {
      print(_listInputController.text.isEmpty);
    });

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          child: Icon(Icons.person, color: Colors.grey[600]),
          onTap: _onUserTap,
        ),
        title: GestureDetector(
          child: Text(auth.username),
          onTap: _onUserTap,
        ),
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _handleSearch,
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _onRefresh(context),
        child: Container(
          child: TaskListWidget(),
        ),
        color: Theme.of(context).primaryColor,
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () {
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
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Enter list title',
                        ),
                        onSubmitted: (String value) {
                          _onListSubmit(value);
                        },
                        textInputAction: TextInputAction.send,
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
                              'Create',
                              style: TEXT_BODY_WHITE,
                            ),
                            onPressed: () =>
                                _onListSubmit(_listInputController.text),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
        child: Container(
          padding: Theme.of(context).platform == TargetPlatform.android
              ? EdgeInsets.all(16.0)
              : EdgeInsets.only(
                  bottom: 20.0,
                  left: 16.0,
                  right: 16.0,
                  top: 16.0,
                ),
          decoration: BoxDecoration(
              color: Colors.grey[800].withOpacity(0.1),
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(16.0),
                right: Radius.circular(16.0),
              )),
          child: Row(
            children: <Widget>[
              Icon(Icons.add),
              SizedBox(
                width: 24.0,
              ),
              Text('New list'),
            ],
          ),
        ),
      ),
    );
  }

  _onRefresh(BuildContext context) async {
    Provider.of<Tasks>(
      context,
      listen: false,
    ).fetchAndRefresh();
  }

  _handleSearch() {
    print('Search...');
  }
}
