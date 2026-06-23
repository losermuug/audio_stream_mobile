import 'dart:ui';
import 'package:streaming_app/features/home/domain/track.dart';
import 'package:streaming_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:streaming_app/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Track> publishTrack({
    required String title,
    required String genre,
    required List<int> audioBytes,
    required String audioFilename,
    List<int>? coverBytes,
    String? coverFilename,
    String? albumName,
    required int durationMs,
  }) async {
    final trackJson = await remoteDataSource.uploadTrack(
      title: title,
      genre: genre,
      audioBytes: audioBytes,
      audioFilename: audioFilename,
      coverBytes: coverBytes,
      coverFilename: coverFilename,
      albumName: albumName,
      durationMs: durationMs,
    );

    return Track(
      id: trackJson['id'] ?? '',
      title: trackJson['title'] ?? '',
      artist: trackJson['artist']?['name'] ?? 'Уран Бүтээлч',
      duration: _formatDuration(durationMs),
      gradientColors: const [
        Color(0xFF2C3E50),
        Color(0xFFFD746C),
      ],
      imagePath: trackJson['coverUrl'],
    );
  }

  String _formatDuration(int ms) {
    final seconds = (ms / 1000).round();
    final mins = seconds ~/ 60;
    final remainingSecs = seconds % 60;
    return '$mins:${remainingSecs.toString().padLeft(2, '0')}';
  }

  @override
  Future<void> updateProfile({
    required String userName,
    required String email,
  }) async {
    await remoteDataSource.updateProfile(
      userName: userName,
      email: email,
    );
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await remoteDataSource.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<List<String>> fetchGenres() async {
    try {
      final list = await remoteDataSource.fetchGenres();
      return list.map((item) => item['name'] as String).toList();
    } catch (e) {
      return const ['Хип Хоп', 'Поп', 'Рок', 'Инди', 'R&B'];
    }
  }
}
