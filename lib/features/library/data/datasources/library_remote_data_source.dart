import 'dart:convert';
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
  }) async {
    final url = Uri.parse('${AudioPlayerService.baseUrl}/graphql');
    final query = {
      'query': '''
        mutation CreatePlaylist(\$name: String!, \$description: String) {
          createPlaylist(input: { name: \$name, description: \$description }) {
            id
            name
            description
            coverUrl
            tracks {
              id
            }
          }
        }
      ''',
      'variables': {
        'name': name,
        'description': description,
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
}
