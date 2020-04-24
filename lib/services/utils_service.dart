import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasks/providers/auth.dart';

class UtilsService {
  /// Returns default Content-Type and Authorization headers.
  Future<Map<String, String>> getDefaultHeaders(Auth authProvider) async {
    final _prefs = await SharedPreferences.getInstance();
    final userData = json.decode(_prefs.get('userData'));

    print(userData['token']);

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${userData['token']}"
    };
  }

  /// Decodes and handle responses unexpected codes.
  ///
  /// Decodes the [response] and validate the expected http [statusCode].
  handleJavaAPIResponse(response, int statusCode) {
    final responseBody = jsonDecode(response.body);

    if (response.statusCode != statusCode) {
      throw HttpException(responseBody['message']);
    }

    return responseBody;
  }

  /// Decodes and handle responses unexpected codes.
  ///
  /// Decodes the [response] and validate the expected http [statusCode].
  handleNodeAPIResponse(response, int statusCode) {
    var decodedResponseBody;
    if (response.body.isNotEmpty) {
      decodedResponseBody = jsonDecode(response.body);
    }

    if (response.statusCode != statusCode) {
      throw HttpException(decodedResponseBody['message']);
    }

    return decodedResponseBody;
  }
}
