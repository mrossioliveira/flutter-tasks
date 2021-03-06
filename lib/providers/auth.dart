import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasks/services/auth_service.dart';
import 'package:tasks/services/auth_service_interface.dart';

class Auth with ChangeNotifier {
  IAuthService authService;

  Auth() {
    authService = new AuthService();
  }

  String _token;
  String _refreshToken;
  DateTime _exp;
  int _userId;
  String _username;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_exp != null && _exp.isAfter(DateTime.now()) && _token != null) {
      return _token;
    }
    return null;
  }

  int get userId {
    return _userId;
  }

  String get username {
    return _username;
  }

  Future<bool> tryAutoLogin() async {
    await authService.refreshToken();
    final _prefs = await SharedPreferences.getInstance();

    if (!_prefs.containsKey('userData')) {
      return false;
    }

    final userData =
        json.decode(_prefs.getString('userData')) as Map<String, dynamic>;

    _userId = userData['userId'];
    _username = userData['username'];
    _token = userData['token'];
    _refreshToken = userData['refreshToken'];
    _exp = DateTime.parse(userData['exp']);

    notifyListeners();
    return true;
  }

  Future<void> signIn(String username, String password) async {
    try {
      final authData = await authService.signIn(username, password);

      _userId = authData.userId;
      _username = authData.username;
      _token = authData.token;
      _refreshToken = authData.refreshToken;
      _exp = authService.extractExpFromToken(_token);

      notifyListeners();
      _saveUserData();
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

  Future<void> refreshToken() async {
    try {
      final refreshedToken = await authService.refreshToken();
      _token = refreshedToken;

      notifyListeners();
      _saveUserData();
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

  Future<void> signOut() async {
    _userId = null;
    _username = null;
    _token = null;
    _exp = null;
    notifyListeners();

    final _prefs = await SharedPreferences.getInstance();
    _prefs.remove('userData');
  }

  Future<void> signUp(String username, String email, String password) async {
    try {
      await authService.signUp(username, email, password);
      await signIn(username, password);

      notifyListeners();
      _saveUserData();
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

  _saveUserData() async {
    final _prefs = await SharedPreferences.getInstance();
    final userData = json.encode({
      'userId': _userId,
      'username': _username,
      'token': _token,
      'refreshToken': _refreshToken,
      'exp': _exp.toIso8601String(),
    });
    _prefs.setString('userData', userData);

    final listPrefs = json.encode({'showCompleted': true});
    _prefs.setString('listPrefs', listPrefs);
  }
}
