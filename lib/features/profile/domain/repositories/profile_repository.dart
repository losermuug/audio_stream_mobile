import 'package:streaming_app/features/home/domain/track.dart';

abstract class ProfileRepository {
  Future<Track> publishTrack({
    required String title,
    required String genre,
    required List<int> audioBytes,
    required String audioFilename,
    List<int>? coverBytes,
    String? coverFilename,
    String? albumName,
    required int durationMs,
  });

  Future<void> updateProfile({
    required String userName,
    required String email,
  });

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<List<String>> fetchGenres();

  Future<List<Track>> fetchMyTracks();

  Future<Track> updateTrack({
    required String id,
    String? title,
    String? coverUrl,
    bool? isPublished,
    List<String>? genres,
  });

  Future<bool> deleteTrack(String id);

  Future<String> uploadCoverImage(List<int> bytes, String filename);
}
