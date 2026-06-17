import 'package:streaming_app/features/home/domain/track.dart';

abstract class ProfileRepository {
  Future<Track> publishTrack({
    required String title,
    required String genre,
    required List<int> audioBytes,
    required String filename,
  });
}
