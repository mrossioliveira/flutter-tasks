import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:tasks/config/api_utils.dart';
import 'package:tasks/dto/create_task_dto.dart';
import 'package:tasks/models/task.dart';
import 'package:tasks/providers/auth.dart';
import 'package:tasks/services/tasks_service_interface.dart';
import 'package:tasks/services/utils_service.dart';

class TasksService extends UtilsService implements ITasksService {
  Auth authProvider;

  TasksService({@required this.authProvider});

  @override
  Future<List<Task>> find() async {
    final url = '${ApiUtils.JAVA_API}/tasks';

    final response = await http.get(
      url,
      headers: getDefaultHeaders(authProvider),
    );

    final responseBody = handleJavaAPIResponse(response, HttpStatus.ok);
    return responseBody
        .map<Task>((jsonList) => Task.fromJson(jsonList))
        .toList();
  }

  @override
  Future<List<Task>> findImportant() async {
    final tasks = await find();
    return tasks.where((task) => task.important);
  }

  @override
  Future<List<Task>> findListless() {
    return null;
  }

  @override
  Future<Task> create(CreateTaskDto createTaskDto) async {
    final url = '${ApiUtils.NODE_API}/tasks';

    final response = await http.post(
      url,
      headers: getDefaultHeaders(authProvider),
      body: json.encode({
        'listId': createTaskDto.listId,
        'title': createTaskDto.title,
        'description': '',
        'important': false,
      }),
    );

    final responseBody = handleNodeAPIResponse(response, HttpStatus.created);
    return Task.fromJson(responseBody);
  }

  @override
  Future<void> delete(int id) async {
    final url = '${ApiUtils.NODE_API}/tasks/$id';

    final response = await http.delete(
      url,
      headers: getDefaultHeaders(authProvider),
    );

    handleNodeAPIResponse(response, HttpStatus.ok);
    return true;
  }

  @override
  Future<Task> updateStatus(int id, String status) async {
    final url = '${ApiUtils.NODE_API}/tasks/$id/status';

    final response = await http.patch(
      url,
      headers: getDefaultHeaders(authProvider),
      body: json.encode({
        'id': id,
        'status': status,
      }),
    );

    final responseBody = handleNodeAPIResponse(response, HttpStatus.ok);
    return Task.fromJson(responseBody);
  }

  @override
  Future<Task> updateImportant(int id, bool important) async {
    final url = '${ApiUtils.NODE_API}/tasks/$id/important';

    final response = await http.patch(
      url,
      headers: getDefaultHeaders(authProvider),
      body: json.encode({
        'id': id,
        'important': important.toString(),
      }),
    );

    final responseBody = handleNodeAPIResponse(response, HttpStatus.ok);
    return Task.fromJson(responseBody);
  }
}
