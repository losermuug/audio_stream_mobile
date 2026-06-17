import 'dart:convert';
import 'package:streaming_app/shared/services/api_client.dart';
import 'package:streaming_app/shared/services/audio_player_service.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource({required this.apiClient});

  Future<Map<String, dynamic>> loginGraphQL(String email, String password) async {
    final url = Uri.parse('${AudioPlayerService.baseUrl}/graphql');
    final query = {
      'query': '''
        mutation Login(\$email: String!, \$password: String!) {
          login(input: { email: \$email, password: \$password }) {
            accessToken
            refreshToken
            user {
              id
              userName
              email
              role
              avatarUrl
            }
          }
        }
      ''',
      'variables': {
        'email': email,
        'password': password,
      }
    };

    final response = await apiClient.post(
      url,
      body: jsonEncode(query),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null) {
        throw Exception(data['errors'][0]['message']);
      }
      return data['data']?['login'] ?? {};
    } else {
      throw Exception('Failed to login: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> registerGraphQL(
    String userName,
    String email,
    String password, {
    String role = 'listener',
  }) async {
    final url = Uri.parse('${AudioPlayerService.baseUrl}/graphql');
    final query = {
      'query': '''
        mutation Register(\$userName: String!, \$email: String!, \$password: String!, \$role: String!) {
          register(input: { userName: \$userName, email: \$email, password: \$password, role: \$role }) {
            accessToken
            refreshToken
            user {
              id
              userName
              email
              role
              avatarUrl
            }
          }
        }
      ''',
      'variables': {
        'userName': userName,
        'email': email,
        'password': password,
        'role': role,
      }
    };

    final response = await apiClient.post(
      url,
      body: jsonEncode(query),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null) {
        throw Exception(data['errors'][0]['message']);
      }
      return data['data']?['register'] ?? {};
    } else {
      throw Exception('Failed to register: ${response.statusCode}');
    }
  }
}
