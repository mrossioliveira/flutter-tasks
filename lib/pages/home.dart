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
    }

    final auth = Provider.of<Auth>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            child: Text(auth.username),
            onTap: () => {
              Navigator.of(context).push(
                new MaterialPageRoute(
                  builder: (context) => SettingsPage(),
                ),
              )
            },
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
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add, color: Colors.white),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
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
                              onPressed: () async {
                                _onListSubmit(_listInputController.text);
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
          },
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
