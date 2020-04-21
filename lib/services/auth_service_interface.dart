import 'package:tasks/models/auth_data.dart';

abstract class IAuthService {
  Future<AuthData> signIn(String username, String password);
  Future<void> signUp(String username, String email, String password);
  DateTime extractExpFromToken(String token);
}
