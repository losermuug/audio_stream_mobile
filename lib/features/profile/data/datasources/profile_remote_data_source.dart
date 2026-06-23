import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:streaming_app/shared/services/api_client.dart';
import 'package:streaming_app/shared/services/audio_player_service.dart';
import 'package:streaming_app/shared/services/auth_session.dart';
import 'package:streaming_app/main.dart';

class ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSource({required this.apiClient});

  Future<Map<String, dynamic>> uploadTrack({
    required String title,
    required String genre,
    required List<int> audioBytes,
    required String audioFilename,
    List<int>? coverBytes,
    String? coverFilename,
    String? albumName,
    required int durationMs,
  }) async {
    final url = Uri.parse('${AudioPlayerService.baseUrl}/tracks/upload');
    final request = http.MultipartRequest('POST', url);

    final token = AuthSession().accessToken;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['title'] = title;
    request.fields['durationMs'] = durationMs.toString();
    request.fields['isPublished'] = 'true';
    request.fields['genres'] = genre;
    if (albumName != null && albumName.isNotEmpty) {
      request.fields['albumTitle'] = albumName;
    }

    request.files.add(
      http.MultipartFile.fromBytes(
        'audio',
        audioBytes,
        filename: audioFilename,
        contentType: MediaType('audio', 'mpeg'),
      ),
    );

    if (coverBytes != null && coverFilename != null) {
      final ext = coverFilename.split('.').last.toLowerCase();
      final mimeSubtype = (ext == 'jpg' || ext == 'jpeg') ? 'jpeg' : (ext == 'png' ? 'png' : 'webp');
      request.files.add(
        http.MultipartFile.fromBytes(
          'cover',
          coverBytes,
          filename: coverFilename,
          contentType: MediaType('image', mimeSubtype),
        ),
      );
    }

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

  Future<List<Map<String, dynamic>>> fetchGenres() async {
    final url = Uri.parse('${AudioPlayerService.baseUrl}/graphql');
    final query = {
      'query': '''
        query GetGenres {
          genres {
            id
            name
            slug
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
      final List raw = data['data']?['genres'] ?? [];
      return List<Map<String, dynamic>>.from(
        raw.map((item) => Map<String, dynamic>.from(item)),
      );
    } else {
      throw Exception('Failed to load genres: ${response.statusCode}');
    }
  }
}
