import 'package:tasks/models/auth_data.dart';

abstract class IAuthService {
  Future<AuthData> signIn(String username, String password);
  DateTime extractExpFromToken(String token);
}
