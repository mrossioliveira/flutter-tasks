import 'dart:convert';
import 'dart:io';

import 'package:tasks/providers/auth.dart';

class UtilsService {
  /// Returns default Content-Type and Authorization headers.
  getDefaultHeaders(Auth authProvider) {
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${authProvider.token}"
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
