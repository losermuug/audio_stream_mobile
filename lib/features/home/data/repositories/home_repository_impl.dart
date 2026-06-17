import 'dart:ui';
import 'package:streaming_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:streaming_app/features/home/domain/playlist.dart';
import 'package:streaming_app/features/home/domain/repositories/home_repository.dart';
import 'package:streaming_app/features/home/domain/track.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Track>> getTracks() async {
    final data = await remoteDataSource.fetchTracksGraphQL();
    final List rawTracks = data['tracks'] ?? [];
    return rawTracks.map((item) => _mapJsonToTrack(item)).toList();
  }

  @override
  Future<List<Playlist>> getPlaylists() async {
    final data = await remoteDataSource.fetchPlaylistsGraphQL();
    final List rawPlaylists = data['playlists'] ?? [];
    
    return rawPlaylists.map((item) {
      final List rawPlaylistTracks = item['tracks'] ?? [];
      final List<Track> playlistTracks = rawPlaylistTracks
          .map((pt) => _mapJsonToTrack(pt['track']))
          .toList();

      return Playlist(
        id: item['id'] ?? '',
        name: item['name'] ?? '',
        description: item['description'],
        coverUrl: item['coverUrl'],
        tracks: playlistTracks,
      );
    }).toList();
  }

  @override
  Future<bool> likeTrack(String trackId) async {
    return remoteDataSource.likeTrackGraphQL(trackId);
  }

  @override
  Future<bool> unlikeTrack(String trackId) async {
    return remoteDataSource.unlikeTrackGraphQL(trackId);
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
}
