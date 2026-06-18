import 'package:shared_preferences/shared_preferences.dart';

class AuthSession {
  static final AuthSession _instance = AuthSession._internal();
  factory AuthSession() => _instance;
  AuthSession._internal();

  String? _accessToken;
  String? _refreshToken;
  String? _userId;
  String? _userName;
  String? _userEmail;
  String? _userRole;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userRole => _userRole;

  bool get isAuthenticated => _accessToken != null;

  static const String _keyAccessToken = 'auth_access_token';
  static const String _keyRefreshToken = 'auth_refresh_token';
  static const String _keyUserId = 'auth_user_id';
  static const String _keyUserName = 'auth_user_name';
  static const String _keyUserEmail = 'auth_user_email';
  static const String _keyUserRole = 'auth_user_role';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_keyAccessToken);
    _refreshToken = prefs.getString(_keyRefreshToken);
    _userId = prefs.getString(_keyUserId);
    _userName = prefs.getString(_keyUserName);
    _userEmail = prefs.getString(_keyUserEmail);
    _userRole = prefs.getString(_keyUserRole);
  }

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String userName,
    required String userEmail,
    required String userRole,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _userId = userId;
    _userName = userName;
    _userEmail = userEmail;
    _userRole = userRole;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, accessToken);
    await prefs.setString(_keyRefreshToken, refreshToken);
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyUserName, userName);
    await prefs.setString(_keyUserEmail, userEmail);
    await prefs.setString(_keyUserRole, userRole);
  }

  Future<void> updateProfile({
    required String userName,
    required String userEmail,
  }) async {
    _userName = userName;
    _userEmail = userEmail;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, userName);
    await prefs.setString(_keyUserEmail, userEmail);
  }

  Future<void> clearSession() async {
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
    _userName = null;
    _userEmail = null;
    _userRole = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserRole);
  }
}
