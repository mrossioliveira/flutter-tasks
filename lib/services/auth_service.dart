import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:tasks/config/api_utils.dart';
import 'package:tasks/models/auth_data.dart';
import 'package:tasks/services/auth_service_interface.dart';
import 'package:tasks/services/utils_service.dart';

class AuthService extends UtilsService implements IAuthService {
  Future<AuthData> signIn(String username, String password) async {
    try {
      final url = '${ApiUtils.NODE_API}/auth/signin';

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final responseBody = handleNodeAPIResponse(response, HttpStatus.created);
      return new AuthData.fromJson(responseBody);
    } catch (e) {
      if (e is SocketException) {
        throw SocketException('Unable to contact server');
      } else if (e is HttpException) {
        throw HttpException(e.message);
      } else {
        throw e;
      }
    }
  }

  /// Extracts the exp in a datetime by paring the [token].
  DateTime extractExpFromToken(String token) {
    final payload = token.split('.')[1];
    var normalized = base64Url.normalize(payload);
    var decoded = utf8.decode(base64Url.decode(normalized));
    final payloadMap = json.decode(decoded);
    return new DateTime.fromMillisecondsSinceEpoch(payloadMap['exp'] * 1000);
  }
}
