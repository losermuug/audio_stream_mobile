import 'package:streaming_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:streaming_app/features/auth/domain/entities/auth_user.dart';
import 'package:streaming_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:streaming_app/shared/services/auth_session.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AuthUser> login({required String email, required String password}) async {
    final payload = await remoteDataSource.loginGraphQL(email, password);
    final userMap = payload['user'] ?? {};

    final user = AuthUser(
      id: userMap['id'] ?? '',
      userName: userMap['userName'] ?? '',
      email: userMap['email'] ?? '',
      role: userMap['role'] ?? '',
      avatarUrl: userMap['avatarUrl'],
    );

    // Save tokens in AuthSession
    await AuthSession().saveSession(
      accessToken: payload['accessToken'] ?? '',
      refreshToken: payload['refreshToken'] ?? '',
      userId: user.id,
      userName: user.userName,
      userEmail: user.email,
      userRole: user.role,
    );

    return user;
  }

  @override
  Future<AuthUser> register({
    required String userName,
    required String email,
    required String password,
    String? role,
  }) async {
    final payload = await remoteDataSource.registerGraphQL(
      userName,
      email,
      password,
      role: role ?? 'listener',
    );
    final userMap = payload['user'] ?? {};

    final user = AuthUser(
      id: userMap['id'] ?? '',
      userName: userMap['userName'] ?? '',
      email: userMap['email'] ?? '',
      role: userMap['role'] ?? '',
      avatarUrl: userMap['avatarUrl'],
    );

    // Save tokens in AuthSession
    await AuthSession().saveSession(
      accessToken: payload['accessToken'] ?? '',
      refreshToken: payload['refreshToken'] ?? '',
      userId: user.id,
      userName: user.userName,
      userEmail: user.email,
      userRole: user.role,
    );

    return user;
  }

  @override
  Future<void> logout() async {
    await AuthSession().clearSession();
  }

  @override
  Future<AuthUser?> tryAutoLogin() async {
    if (AuthSession().isAuthenticated) {
      return AuthUser(
        id: AuthSession().userId ?? '',
        userName: AuthSession().userName ?? '',
        email: AuthSession().userEmail ?? '',
        role: AuthSession().userRole ?? '',
      );
    }
    return null;
  }
}
