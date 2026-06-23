import 'package:streaming_app/features/home/domain/track.dart';
import 'package:streaming_app/features/home/domain/playlist.dart';

abstract class LibraryRepository {
  Future<List<Track>> getLikedTracks({int limit = 20, int offset = 0});
  Future<List<Playlist>> getMyPlaylists({int limit = 20, int offset = 0});
  Future<Playlist> createPlaylist({required String name, String? description, String? coverUrl, String? visibility});
  Future<Playlist> addTrackToPlaylist({required String playlistId, required String trackId});
  Future<int> getPlayHistoryCount();
  Future<String> uploadCover(List<int> bytes, String filename);
  Future<bool> likePlaylist(String playlistId);
  Future<bool> unlikePlaylist(String playlistId);
}
