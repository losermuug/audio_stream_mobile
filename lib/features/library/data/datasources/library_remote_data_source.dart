import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:streaming_app/main.dart';
import 'package:streaming_app/shared/services/auth_session.dart';
import 'package:streaming_app/shared/services/api_client.dart';
import 'package:streaming_app/shared/services/audio_player_service.dart';

class LibraryRemoteDataSource {
  final ApiClient client;

  LibraryRemoteDataSource({required this.client});

  Future<Map<String, dynamic>> fetchLikedTracksGraphQL({int limit = 20, int offset = 0}) async {
    final url = Uri.parse('${AudioPlayerService.baseUrl}/graphql');
    final query = {
      'query': '''
        query GetLikedTracks(\$limit: Int, \$offset: Int) {
          likedTracks(limit: \$limit, offset: \$offset) {
            id
            title
            durationMs
            coverUrl
            isLiked
            artist {
              name
            }
          }
        }
      ''',
      'variables': {
        'limit': limit,
        'offset': offset,
      }
    };

    final response = await client.post(
      url,
      body: jsonEncode(query),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null) {
        throw Exception(data['errors'][0]['message']);
      }
      return data['data'] ?? {};
    } else {
      throw Exception('Failed to fetch liked tracks: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchMyPlaylistsGraphQL({int limit = 20, int offset = 0}) async {
    final url = Uri.parse('${AudioPlayerService.baseUrl}/graphql');
    final query = {
      'query': '''
        query GetMyPlaylists(\$limit: Int, \$offset: Int) {
          playlists(mine: true, limit: \$limit, offset: \$offset) {
            id
            name
            description
            coverUrl
            visibility
            isLiked
            likeCount
            tracks {
              id
              track {
                id
                title
                durationMs
                coverUrl
                isLiked
                artist {
                  name
                }
              }
            }
          }
        }
      ''',
      'variables': {
        'limit': limit,
        'offset': offset,
      }
    };

    final response = await client.post(
      url,
      body: jsonEncode(query),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null) {
        throw Exception(data['errors'][0]['message']);
      }
      return data['data'] ?? {};
    } else {
      throw Exception('Failed to fetch playlists: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> createPlaylistGraphQL({
    required String name,
    String? description,
    String? coverUrl,
    String? visibility,
  }) async {
    final url = Uri.parse('${AudioPlayerService.baseUrl}/graphql');
    final query = {
      'query': '''
        mutation CreatePlaylist(\$name: String!, \$description: String, \$coverUrl: String, \$visibility: String) {
          createPlaylist(input: { name: \$name, description: \$description, coverUrl: \$coverUrl, visibility: \$visibility }) {
            id
            name
            description
            coverUrl
            visibility
            isLiked
            likeCount
            tracks {
              id
            }
          }
        }
      ''',
      'variables': {
        'name': name,
        'description': description,
        'coverUrl': coverUrl,
        'visibility': visibility,
      }
    };

    final response = await client.post(
      url,
      body: jsonEncode(query),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null) {
        throw Exception(data['errors'][0]['message']);
      }
      return data['data']?['createPlaylist'] ?? {};
    } else {
      throw Exception('Failed to create playlist: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> addTrackToPlaylistGraphQL({
    required String playlistId,
    required String trackId,
  }) async {
    final url = Uri.parse('${AudioPlayerService.baseUrl}/graphql');
    final query = {
      'query': '''
        mutation AddTrackToPlaylist(\$playlistId: ID!, \$trackId: ID!) {
          addTrackToPlaylist(playlistId: \$playlistId, trackId: \$trackId) {
            id
            name
            description
            coverUrl
            tracks {
              id
              track {
                id
                title
                durationMs
                coverUrl
                isLiked
                artist {
                  name
                }
              }
            }
          }
        }
      ''',
      'variables': {
        'playlistId': playlistId,
        'trackId': trackId,
      }
    };

    final response = await client.post(
      url,
      body: jsonEncode(query),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null) {
        throw Exception(data['errors'][0]['message']);
      }
      return data['data']?['addTrackToPlaylist'] ?? {};
    } else {
      throw Exception('Failed to add track to playlist: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchPlayHistoryGraphQL({int limit = 50}) async {
    final url = Uri.parse('${AudioPlayerService.baseUrl}/graphql');
    final query = {
      'query': '''
        query GetPlayHistory(\$limit: Int) {
          playHistory(limit: \$limit) {
            id
          }
        }
      ''',
      'variables': {
        'limit': limit,
      }
    };

    final response = await client.post(
      url,
      body: jsonEncode(query),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null) {
        throw Exception(data['errors'][0]['message']);
      }
      return data['data'] ?? {};
    } else {
      throw Exception('Failed to fetch play history: ${response.statusCode}');
    }
  }

  Future<String> uploadCover(List<int> bytes, String filename) async {
    final url = Uri.parse('${AudioPlayerService.baseUrl}/tracks/upload-cover');
    final request = http.MultipartRequest('POST', url);

    final token = AuthSession().accessToken;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final ext = filename.split('.').last.toLowerCase();
    final mimeSubtype = (ext == 'jpg' || ext == 'jpeg') ? 'jpeg' : (ext == 'png' ? 'png' : 'webp');
    request.files.add(
      http.MultipartFile.fromBytes(
        'cover',
        bytes,
        filename: filename,
        contentType: MediaType('image', mimeSubtype),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['coverUrl'] ?? '';
    } else {
      if (response.statusCode == 401) {
        await AuthSession().clearSession();
        navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
      }
      Map<String, dynamic> errJson = {};
      try {
        errJson = jsonDecode(response.body);
      } catch (_) {}
      throw Exception(errJson['message'] ?? 'Failed to upload cover: ${response.statusCode}');
    }
  }

  Future<bool> likePlaylistGraphQL(String playlistId) async {
    final url = Uri.parse('${AudioPlayerService.baseUrl}/graphql');
    final query = {
      'query': '''
        mutation LikePlaylist(\$playlistId: ID!) {
          likePlaylist(playlistId: \$playlistId)
        }
      ''',
      'variables': {
        'playlistId': playlistId,
      }
    };

    final response = await client.post(
      url,
      body: jsonEncode(query),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null) {
        throw Exception(data['errors'][0]['message']);
      }
      return data['data']?['likePlaylist'] ?? false;
    } else {
      throw Exception('Failed to like playlist: ${response.statusCode}');
    }
  }

  Future<bool> unlikePlaylistGraphQL(String playlistId) async {
    final url = Uri.parse('${AudioPlayerService.baseUrl}/graphql');
    final query = {
      'query': '''
        mutation UnlikePlaylist(\$playlistId: ID!) {
          unlikePlaylist(playlistId: \$playlistId)
        }
      ''',
      'variables': {
        'playlistId': playlistId,
      }
    };

    final response = await client.post(
      url,
      body: jsonEncode(query),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null) {
        throw Exception(data['errors'][0]['message']);
      }
      return data['data']?['unlikePlaylist'] ?? false;
    } else {
      throw Exception('Failed to unlike playlist: ${response.statusCode}');
    }
  }
}
