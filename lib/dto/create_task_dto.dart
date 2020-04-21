import 'package:flutter/material.dart';

class CreateTaskDto {
  String title;
  int listId;
  bool important;

  CreateTaskDto({@required this.title, @required this.listId, this.important});
}
