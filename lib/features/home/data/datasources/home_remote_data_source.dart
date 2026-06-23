import 'dart:convert';
import 'package:streaming_app/shared/services/api_client.dart';
import 'package:streaming_app/shared/services/audio_player_service.dart';

class HomeRemoteDataSource {
  final ApiClient client;

  HomeRemoteDataSource({required this.client});

  Future<Map<String, dynamic>> fetchTracksGraphQL() async {
    final url = Uri.parse('${AudioPlayerService.baseUrl}/graphql');
    final query = {
      'query': '''
        query {
          tracks {
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
      '''
    };

    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(query),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null) {
        throw Exception(data['errors'][0]['message']);
      }
      return data['data'] ?? {};
    } else {
      throw Exception('Failed to fetch tracks: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchPlaylistsGraphQL() async {
    final url = Uri.parse('${AudioPlayerService.baseUrl}/graphql');
    final query = {
      'query': '''
        query {
          playlists {
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
      '''
    };

    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
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

  Future<bool> likeTrackGraphQL(String trackId) async {
    final url = Uri.parse('${AudioPlayerService.baseUrl}/graphql');
    final query = {
      'query': '''
        mutation LikeTrack(\$trackId: ID!) {
          likeTrack(trackId: \$trackId)
        }
      ''',
      'variables': {
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
      return data['data']?['likeTrack'] ?? false;
    } else {
      throw Exception('Failed to like track: ${response.statusCode}');
    }
  }

  Future<bool> unlikeTrackGraphQL(String trackId) async {
    final url = Uri.parse('${AudioPlayerService.baseUrl}/graphql');
    final query = {
      'query': '''
        mutation UnlikeTrack(\$trackId: ID!) {
          unlikeTrack(trackId: \$trackId)
        }
      ''',
      'variables': {
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
      return data['data']?['unlikeTrack'] ?? false;
    } else {
      throw Exception('Failed to unlike track: ${response.statusCode}');
    }
  }
}
