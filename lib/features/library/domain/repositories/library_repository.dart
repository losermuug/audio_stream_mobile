import 'package:streaming_app/features/home/domain/track.dart';
import 'package:streaming_app/features/home/domain/playlist.dart';

abstract class LibraryRepository {
  Future<List<Track>> getLikedTracks({int limit = 20, int offset = 0});
  Future<List<Playlist>> getMyPlaylists({int limit = 20, int offset = 0});
  Future<Playlist> createPlaylist({required String name, String? description});
  Future<Playlist> addTrackToPlaylist({required String playlistId, required String trackId});
}
