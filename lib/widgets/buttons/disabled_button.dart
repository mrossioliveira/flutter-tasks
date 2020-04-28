import 'dart:ui';

import 'package:flutter/material.dart';

class DisabledButton extends StatefulWidget {
  final Text text;
  final Color color;
  final Function onPressed;

  DisabledButton({this.text, this.color, this.onPressed});

  @override
  _DisabledButtonState createState() => _DisabledButtonState();
}

class _DisabledButtonState extends State<DisabledButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: widget.color,
      child: widget.text,
      onPressed: widget.onPressed,
    );
  }
}
