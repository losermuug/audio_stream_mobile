import 'dart:ui';
import 'package:streaming_app/features/search/domain/repositories/search_repository.dart';
import 'package:streaming_app/features/search/data/datasources/search_remote_data_source.dart';
import 'package:streaming_app/features/home/domain/track.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;

  SearchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Track>> searchTracks(String query) async {
    if (query.isEmpty) return [];
    final data = await remoteDataSource.fetchSearchGraphQL(query);
    final List rawTracks = data['tracks'] ?? [];
    return rawTracks.map((item) => _mapJsonToTrack(item)).toList();
  }

  Track _mapJsonToTrack(Map<String, dynamic> item) {
    final int durMs = item['durationMs'] ?? 180000;
    final int minutes = (durMs / 60000).floor();
    final int seconds = ((durMs % 60000) / 1000).round();
    final durationStr = '$minutes:${seconds.toString().padLeft(2, '0')}';

    return Track(
      id: item['id'] ?? '',
      title: item['title'] ?? 'Unknown Title',
      artist: item['artist']?['name'] ?? 'Unknown Artist',
      duration: durationStr,
      gradientColors: const [
        Color(0xFF2C3E50),
        Color(0xFFFD746C)
      ],
      imagePath: item['coverUrl'],
      isLiked: item['isLiked'] ?? false,
    );
  }

  @override
  Future<List<String>> fetchGenres() async {
    try {
      final list = await remoteDataSource.fetchGenres();
      return list.map((item) => item['name'] as String).toList();
    } catch (e) {
      // Fallback standard genres
      return const ['Поп', 'Хип Хоп', 'Рок', 'Инди', 'R&B', 'Лофи', 'Акустик'];
    }
  }
}
