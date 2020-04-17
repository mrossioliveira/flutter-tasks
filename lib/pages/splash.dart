import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text(
            '.tasks',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 32,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ),
    );
  }
}
