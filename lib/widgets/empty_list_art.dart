import 'package:flutter/material.dart';

class EmptyList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 240,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[850].withOpacity(0.1),
          borderRadius: BorderRadius.all(
            Radius.circular(4.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.check_circle,
              size: 24.0,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(
              height: 4.0,
            ),
            Text(
              'All done here',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w200,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
