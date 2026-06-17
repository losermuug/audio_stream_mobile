import 'package:streaming_app/features/home/domain/track.dart';

abstract class SearchRepository {
  Future<List<Track>> searchTracks(String query);
}
