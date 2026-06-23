import 'dart:ui';
import 'package:streaming_app/features/library/domain/repositories/library_repository.dart';
import 'package:streaming_app/features/library/data/datasources/library_remote_data_source.dart';
import 'package:streaming_app/features/home/domain/track.dart';
import 'package:streaming_app/features/home/domain/playlist.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryRemoteDataSource remoteDataSource;

  LibraryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Track>> getLikedTracks({int limit = 20, int offset = 0}) async {
    final data = await remoteDataSource.fetchLikedTracksGraphQL(limit: limit, offset: offset);
    final List rawTracks = data['likedTracks'] ?? [];
    return rawTracks.map((item) => _mapJsonToTrack(item)).toList();
  }

  @override
  Future<List<Playlist>> getMyPlaylists({int limit = 20, int offset = 0}) async {
    final data = await remoteDataSource.fetchMyPlaylistsGraphQL(limit: limit, offset: offset);
    final List rawPlaylists = data['playlists'] ?? [];
    return rawPlaylists.map((item) => _mapJsonToPlaylist(item)).toList();
  }

  @override
  Future<Playlist> createPlaylist({required String name, String? description, String? coverUrl, String? visibility}) async {
    final data = await remoteDataSource.createPlaylistGraphQL(name: name, description: description, coverUrl: coverUrl, visibility: visibility);
    return _mapJsonToPlaylist(data);
  }

  @override
  Future<Playlist> addTrackToPlaylist({required String playlistId, required String trackId}) async {
    final data = await remoteDataSource.addTrackToPlaylistGraphQL(playlistId: playlistId, trackId: trackId);
    return _mapJsonToPlaylist(data);
  }

  Playlist _mapJsonToPlaylist(Map<String, dynamic> item) {
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
      visibility: item['visibility'],
      isLiked: item['isLiked'] ?? false,
      likeCount: int.tryParse(item['likeCount'] ?? '0') ?? 0,
    );
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
  Future<int> getPlayHistoryCount() async {
    try {
      final data = await remoteDataSource.fetchPlayHistoryGraphQL(limit: 100);
      final List rawList = data['playHistory'] ?? [];
      return rawList.length;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<String> uploadCover(List<int> bytes, String filename) async {
    return remoteDataSource.uploadCover(bytes, filename);
  }

  @override
  Future<bool> likePlaylist(String playlistId) async {
    return remoteDataSource.likePlaylistGraphQL(playlistId);
  }

  @override
  Future<bool> unlikePlaylist(String playlistId) async {
    return remoteDataSource.unlikePlaylistGraphQL(playlistId);
  }
}
