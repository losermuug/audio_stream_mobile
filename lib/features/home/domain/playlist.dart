import 'package:streaming_app/features/home/domain/track.dart';

class Playlist {
  final String id;
  final String name;
  final String? description;
  final String? coverUrl;
  final List<Track> tracks;
  final String? visibility;
  final bool isLiked;
  final int likeCount;

  const Playlist({
    required this.id,
    required this.name,
    this.description,
    this.coverUrl,
    required this.tracks,
    this.visibility,
    this.isLiked = false,
    this.likeCount = 0,
  });
}
