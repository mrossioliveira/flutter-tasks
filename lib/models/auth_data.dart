import 'package:flutter/material.dart';

class AuthData {
  int userId;
  String username;
  String token;
  String refreshToken;

  AuthData({
    @required this.userId,
    @required this.username,
    @required this.token,
    @required this.refreshToken,
  });

  factory AuthData.fromJson(Map<String, dynamic> jsonData) {
    return AuthData(
      userId: jsonData['userId'],
      username: jsonData['username'],
      token: jsonData['accessToken'],
      refreshToken: jsonData['refreshToken'],
    );
  }
}
