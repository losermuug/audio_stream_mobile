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
    required String filename,
  }) async {
    final artistId = await remoteDataSource.fetchFirstArtistId();
    if (artistId.isEmpty) {
      throw Exception('Өгөгдлийн сангаас уран бүтээлч олдсонгүй. Эхлээд системээ seed хийнэ үү.');
    }

    final trackJson = await remoteDataSource.uploadTrack(
      title: title,
      artistId: artistId,
      genre: genre,
      audioBytes: audioBytes,
      filename: filename,
    );

    return Track(
      id: trackJson['id'] ?? '',
      title: trackJson['title'] ?? '',
      artist: trackJson['artist']?['name'] ?? 'Уран Бүтээлч',
      duration: '3:20',
      gradientColors: const [
        Color(0xFF2C3E50),
        Color(0xFFFD746C),
      ],
      imagePath: trackJson['coverUrl'],
    );
  }
}
