import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tasks/providers/auth.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Settings'),
      ),
      body: Container(
        child: Center(
          child: FlatButton(
            child: Text('Sign out'),
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<Auth>(context, listen: false).signOut();
            },
          ),
        ),
      ),
    );
  }
}
