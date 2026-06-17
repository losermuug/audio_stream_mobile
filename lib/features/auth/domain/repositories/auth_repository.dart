import 'package:streaming_app/features/auth/domain/entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser> login({required String email, required String password});
  Future<AuthUser> register({
    required String userName,
    required String email,
    required String password,
    String? role,
  });
  Future<void> logout();
  Future<AuthUser?> tryAutoLogin();
}
