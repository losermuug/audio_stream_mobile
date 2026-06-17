import 'package:streaming_app/features/home/domain/playlist.dart';
import 'package:streaming_app/features/home/domain/track.dart';

abstract class HomeRepository {
  Future<List<Track>> getTracks();
  Future<List<Playlist>> getPlaylists();
  Future<bool> likeTrack(String trackId);
  Future<bool> unlikeTrack(String trackId);
}
