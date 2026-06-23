import 'dart:convert';
import 'package:streaming_app/shared/services/api_client.dart';
import 'package:streaming_app/shared/services/audio_player_service.dart';

class SearchRemoteDataSource {
  final ApiClient client;

  SearchRemoteDataSource({required this.client});

  Future<Map<String, dynamic>> fetchSearchGraphQL(String queryText) async {
    final url = Uri.parse('${AudioPlayerService.baseUrl}/graphql');
    final query = {
      'query': '''
        query Search(\$q: String!) {
          search(q: \$q) {
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
        }
      ''',
      'variables': {
        'q': queryText,
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
      return data['data']?['search'] ?? {};
    } else {
      throw Exception('Failed to search: ${response.statusCode}');
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

    final response = await client.post(
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

