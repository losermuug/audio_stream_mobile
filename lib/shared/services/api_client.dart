import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:streaming_app/shared/services/auth_session.dart';
import 'package:streaming_app/main.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final http.Client _client = http.Client();

  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final Map<String, String> mergedHeaders = {
      'Content-Type': 'application/json',
      ...?headers,
    };

    final token = AuthSession().accessToken;
    if (token != null) {
      mergedHeaders['Authorization'] = 'Bearer $token';
    }

    final response = await _client.post(
      url,
      headers: mergedHeaders,
      body: body,
      encoding: encoding,
    );

    if (response.statusCode == 401 || _isGraphQLUnauthorized(response)) {
      await AuthSession().clearSession();
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
    }

    return response;
  }

  bool _isGraphQLUnauthorized(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic> && data['errors'] != null) {
        final List errors = data['errors'];
        for (var err in errors) {
          if (err is Map<String, dynamic> && err['message'] == 'Unauthorized') {
            return true;
          }
        }
      }
    } catch (_) {}
    return false;
  }
}
