import 'package:flutter/foundation.dart';
import 'dart:async';

/// https://stackoverflow.com/questions/51791501/how-to-debounce-textfield-onchange-in-dart/55119208#55119208
class Debouncer {
  final int milliseconds;
  VoidCallback action;
  Timer _timer;

  Debouncer({this.milliseconds});

  run(VoidCallback action) {
    if (_timer != null) {
      _timer.cancel();
    }

    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
