import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http_interceptor/http_client_with_interceptor.dart';

import 'package:tasks/config/api_utils.dart';
import 'package:tasks/dto/list_update_dto.dart';
import 'package:tasks/services/http_interceptor.dart';
import 'package:tasks/services/lists_service_interface.dart';
import 'package:tasks/services/utils_service.dart';
import 'package:tasks/models/list.dart';

class ListsService extends UtilsService implements IListsService {
  Client client;

  ListsService() {
    client = HttpClientWithInterceptor.build(
      interceptors: [HttpInterceptor()],
      requestTimeout: Duration(seconds: 5),
    );
  }

  /// Get all tasks through the API.
  @override
  Future<List<TaskList>> find() async {
    final url = '${ApiUtils.NODE_API}/lists';

    final response = await client.get(
      url,
      headers: await getDefaultHeaders(),
    );

    final responseBody = handleJavaAPIResponse(response, HttpStatus.ok);
    return responseBody
        .map<TaskList>((jsonList) => TaskList.fromJson(jsonList))
        .toList();
  }

  @override
  Future<TaskList> findById(int id) async {
    final url = '${ApiUtils.NODE_API}/lists/$id';

    final response = await client.get(
      url,
      headers: await getDefaultHeaders(),
    );

    final responseBody = handleJavaAPIResponse(response, HttpStatus.ok);
    return TaskList.fromJson(responseBody);
  }

  /// Add a new list through the API.
  @override
  Future<TaskList> create(TaskList list) async {
    try {
      final url = '${ApiUtils.NODE_API}/lists';

      final response = await client.post(
        url,
        headers: await getDefaultHeaders(),
        body: json.encode({
          'title': list.title,
        }),
      );

      final responseBody = handleNodeAPIResponse(response, HttpStatus.created);
      return TaskList.fromJson(responseBody);
    } catch (e) {
      throw e;
    }
  }

  /// Update the list through the API.
  @override
  Future<TaskList> update(TaskListUpdateDto updateDto) async {
    final url = '${ApiUtils.NODE_API}/lists/${updateDto.id}';

    final response = await client.patch(
      url,
      headers: await getDefaultHeaders(),
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

    final response = await client.delete(
      url,
      headers: await getDefaultHeaders(),
    );

    handleNodeAPIResponse(response, HttpStatus.ok);
    return true;
  }
}
