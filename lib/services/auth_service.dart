import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tasks/config/api_utils.dart';
import 'package:tasks/models/auth_data.dart';
import 'package:tasks/services/auth_service_interface.dart';
import 'package:tasks/services/utils_service.dart';

class AuthService extends UtilsService implements IAuthService {
  AuthService();

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

  Future<String> refreshToken() async {
    try {
      final _prefs = await SharedPreferences.getInstance();
      final userData = json.decode(_prefs.get('userData'));

      final url = '${ApiUtils.NODE_API}/auth/refresh';

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
          {
            'username': userData['username'],
            'refreshToken': userData['refreshToken'],
          },
        ),
      );

      final responseBody = jsonDecode(response.body);
      userData['token'] = responseBody['accessToken'];
      _prefs.setString('userData', json.encode(userData));

      return responseBody['accessToken'];
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

  @override
  Future<void> signUp(String username, String email, String password) async {
    try {
      final url = '${ApiUtils.NODE_API}/auth/signup';

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      handleNodeAPIResponse(response, HttpStatus.created);
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

  /// Extracts the exp in a datetime by parsing the [token].
  DateTime extractExpFromToken(String token) {
    final payload = token.split('.')[1];
    var normalized = base64Url.normalize(payload);
    var decoded = utf8.decode(base64Url.decode(normalized));
    final payloadMap = json.decode(decoded);
    return new DateTime.fromMillisecondsSinceEpoch(payloadMap['exp'] * 1000);
  }

  /// Extracts the iat in a datetime by parsing the [token].
  Future<DateTime> extractIatFromToken() async {
    final _prefs = await SharedPreferences.getInstance();
    final userData = json.decode(_prefs.get('userData'));
    final token = userData['token'];

    final payload = token.split('.')[1];
    var normalized = base64Url.normalize(payload);
    var decoded = utf8.decode(base64Url.decode(normalized));
    final payloadMap = json.decode(decoded);
    return new DateTime.fromMillisecondsSinceEpoch(payloadMap['iat'] * 1000);
  }

  /// Refreshes the token every 15 min and in app init.
  Future<void> handleTokenRefresh() async {
    DateTime iat = await extractIatFromToken();
    DateTime limit = iat.add(Duration(minutes: 15));

    if (DateTime.now().isAfter(limit)) {
      refreshToken();
    }
  }
}
