import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:http/http.dart';
import 'package:http_interceptor/http_interceptor.dart';

import 'package:tasks/config/api_utils.dart';
import 'package:tasks/dto/create_task_dto.dart';
import 'package:tasks/dto/update_task_dto.dart';
import 'package:tasks/models/task.dart';
import 'package:tasks/providers/auth.dart';
import 'package:tasks/services/expired_token_retry_policy.dart';
import 'package:tasks/services/http_interceptor.dart';
import 'package:tasks/services/tasks_service_interface.dart';
import 'package:tasks/services/utils_service.dart';

class TasksService extends UtilsService implements ITasksService {
  Client client;
  Auth authProvider;

  TasksService({@required this.authProvider}) {
    client = client = HttpClientWithInterceptor.build(
      interceptors: [HttpInterceptor()],
      retryPolicy: ExpiredTokenRetryPolicy(),
    );
  }

  @override
  Future<List<Task>> find() async {
    final url = '${ApiUtils.JAVA_API}/tasks';

    final response = await client.get(
      url,
      headers: await getDefaultHeaders(authProvider),
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

    final response = await client.post(
      url,
      headers: await getDefaultHeaders(authProvider),
      body: json.encode({
        'listId': createTaskDto.listId,
        'title': createTaskDto.title,
        'description': '',
        'important': createTaskDto.important,
      }),
    );

    final responseBody = handleNodeAPIResponse(response, HttpStatus.created);
    return Task.fromJson(responseBody);
  }

  @override
  Future<void> delete(int id) async {
    final url = '${ApiUtils.NODE_API}/tasks/$id';

    final response = await client.delete(
      url,
      headers: await getDefaultHeaders(authProvider),
    );

    handleNodeAPIResponse(response, HttpStatus.ok);
    return true;
  }

  @override
  Future<Task> update(int id, UpdateTaskDto updateTaskDto) async {
    final url = '${ApiUtils.NODE_API}/tasks/$id';

    final response = await client.patch(
      url,
      headers: await getDefaultHeaders(authProvider),
      body: json.encode({
        'title': updateTaskDto.title,
        'description': updateTaskDto.notes == null ? '' : updateTaskDto.notes,
      }),
    );

    final responseBody = handleNodeAPIResponse(response, HttpStatus.ok);
    return Task.fromJson(responseBody);
  }

  @override
  Future<Task> updateStatus(int id, String status) async {
    final url = '${ApiUtils.NODE_API}/tasks/$id/status';

    final response = await client.patch(
      url,
      headers: await getDefaultHeaders(authProvider),
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

    final response = await client.patch(
      url,
      headers: await getDefaultHeaders(authProvider),
      body: json.encode({
        'id': id,
        'important': important.toString(),
      }),
    );

    final responseBody = handleNodeAPIResponse(response, HttpStatus.ok);
    return Task.fromJson(responseBody);
  }
}
