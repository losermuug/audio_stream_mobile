import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:streaming_app/shared/services/api_client.dart';
import 'package:streaming_app/shared/services/audio_player_service.dart';
import 'package:streaming_app/shared/services/auth_session.dart';
import 'package:streaming_app/main.dart';

class ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSource({required this.apiClient});

  Future<String> fetchFirstArtistId() async {
    final url = Uri.parse('${AudioPlayerService.baseUrl}/graphql');
    final query = {
      'query': '''
        query {
          artists(limit: 1) {
            id
          }
        }
      '''
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
      final List list = data['data']?['artists'] ?? [];
      if (list.isNotEmpty) {
        return list.first['id'] ?? '';
      }
      return '';
    } else {
      throw Exception('Failed to fetch artist ID: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> uploadTrack({
    required String title,
    required String artistId,
    required String genre,
    required List<int> audioBytes,
    required String filename,
  }) async {
    final url = Uri.parse('${AudioPlayerService.baseUrl}/tracks/upload');
    final request = http.MultipartRequest('POST', url);

    final token = AuthSession().accessToken;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['title'] = title;
    request.fields['artistId'] = artistId;
    request.fields['durationMs'] = '200000'; // 3:20
    request.fields['isPublished'] = 'true';
    request.fields['genres'] = genre;

    request.files.add(
      http.MultipartFile.fromBytes(
        'audio',
        audioBytes,
        filename: filename,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      if (response.statusCode == 401) {
        await AuthSession().clearSession();
        navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
      }
      Map<String, dynamic> errJson = {};
      try {
        errJson = jsonDecode(response.body);
      } catch (_) {}
      throw Exception(errJson['message'] ?? 'Failed to upload track: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String userName,
    required String email,
  }) async {
    final url = Uri.parse('${AudioPlayerService.baseUrl}/graphql');
    final query = {
      'query': r'''
        mutation UpdateUser($input: UpdateUserInput!) {
          updateUser(input: $input) {
            id
            userName
            email
          }
        }
      ''',
      'variables': {
        'input': {
          'userName': userName,
          'email': email,
        }
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
      return data['data']?['updateUser'] ?? {};
    } else {
      throw Exception('Хэрэглэгчийн мэдээллийг шинэчлэхэд алдаа гарлаа: ${response.statusCode}');
    }
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final url = Uri.parse('${AudioPlayerService.baseUrl}/graphql');
    final query = {
      'query': r'''
        mutation ChangePassword($oldPassword: String!, $newPassword: String!) {
          changePassword(oldPassword: $oldPassword, newPassword: $newPassword)
        }
      ''',
      'variables': {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
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
      return data['data']?['changePassword'] ?? false;
    } else {
      throw Exception('Нууц үг солиход алдаа гарлаа: ${response.statusCode}');
    }
  }
}
