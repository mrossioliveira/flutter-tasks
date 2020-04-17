import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:tasks/config/api_utils.dart';
import 'package:tasks/dto/list_update_dto.dart';
import 'package:tasks/providers/auth.dart';
import 'package:tasks/services/lists_service_interface.dart';
import 'package:tasks/services/utils_service.dart';
import 'package:tasks/models/list.dart';

class ListsService extends UtilsService implements IListsService {
  Auth authProvider;

  ListsService({@required this.authProvider});

  /// Get all tasks through the API.
  @override
  Future<List<TaskList>> find() async {
    final url = '${ApiUtils.JAVA_API}/lists';

    final response =
        await http.get(url, headers: getDefaultHeaders(authProvider));

    final responseBody = handleJavaAPIResponse(response, HttpStatus.ok);
    return responseBody
        .map<TaskList>((jsonTask) => TaskList.fromJson(jsonTask))
        .toList();
  }

  /// Add a new list through the API.
  @override
  Future<TaskList> create(TaskList list) async {
    final url = '${ApiUtils.NODE_API}/lists';

    final response = await http.post(
      url,
      headers: getDefaultHeaders(authProvider),
      body: json.encode({
        'title': list.title,
      }),
    );

    final responseBody = handleNodeAPIResponse(response, HttpStatus.created);
    return TaskList.fromJson(responseBody);
  }

  /// Update the list through the API.
  @override
  Future<TaskList> update(TaskListUpdateDto updateDto) async {
    final url = '${ApiUtils.NODE_API}/lists/${updateDto.id}';

    final response = await http.patch(
      url,
      headers: getDefaultHeaders(authProvider),
      body: json.encode({
        'title': updateDto.title,
      }),
    );

    final responseBody = handleNodeAPIResponse(response, HttpStatus.ok);
    return TaskList.fromJson(responseBody);
  }

  /// Update the list through the API.
  @override
  Future<void> delete(int id) async {
    final url = '${ApiUtils.NODE_API}/lists/$id';

    final response = await http.delete(
      url,
      headers: getDefaultHeaders(authProvider),
    );

    handleNodeAPIResponse(response, HttpStatus.ok);
    return true;
  }
}
