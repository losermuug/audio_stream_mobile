import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';
import 'package:streaming_app/features/home/domain/playlist.dart';
import 'package:streaming_app/features/home/domain/track.dart';
import 'package:streaming_app/features/home/presentation/widgets/track_tile.dart';
import 'package:streaming_app/shared/services/audio_player_service.dart';
import 'package:streaming_app/shared/services/api_client.dart';
import 'package:streaming_app/features/library/domain/repositories/library_repository.dart';
import 'package:streaming_app/features/library/data/repositories/library_repository_impl.dart';
import 'package:streaming_app/features/library/data/datasources/library_remote_data_source.dart';
import 'package:streaming_app/shared/widgets/custom_toast.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final Playlist playlist;
  final void Function(Track track) onTrackSelected;

  const PlaylistDetailScreen({
    super.key,
    required this.playlist,
    required this.onTrackSelected,
  });

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  late bool _isLiked;
  late int _likeCount;
  late final LibraryRepository _libraryRepository;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.playlist.isLiked;
    _likeCount = widget.playlist.likeCount;
    _libraryRepository = LibraryRepositoryImpl(
      remoteDataSource: LibraryRemoteDataSource(
        client: ApiClient(),
      ),
    );
  }

  Future<void> _toggleLike() async {
    final nextLiked = !_isLiked;
    setState(() {
      _isLiked = nextLiked;
      _likeCount = nextLiked ? _likeCount + 1 : _likeCount - 1;
    });

    try {
      bool success;
      if (nextLiked) {
        success = await _libraryRepository.likePlaylist(widget.playlist.id);
      } else {
        success = await _libraryRepository.unlikePlaylist(widget.playlist.id);
      }
      if (!success) throw Exception('API returned failure');
    } catch (e) {
      setState(() {
        _isLiked = !_isLiked;
        _likeCount = _isLiked ? _likeCount + 1 : _likeCount - 1;
      });
      if (mounted) {
        CustomToast.show(
          context,
          'Тоглуулах жагсаалтад лайк дарахад алдаа гарлаа: $e',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Sleek minimalist App Bar
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            pinned: true,
            expandedHeight: 220,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E1E1E), Color(0xFF000000)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  image: widget.playlist.coverUrl != null
                      ? DecorationImage(
                          image: NetworkImage('${AudioPlayerService.baseUrl}${widget.playlist.coverUrl}'),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: widget.playlist.coverUrl != null ? 0.65 : 0.0),
                        Colors.black
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          widget.playlist.name,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.8,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.playlist.description != null && widget.playlist.description!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            widget.playlist.description!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          '${widget.playlist.tracks.length} дуу',
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Play All Button Section + Like Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  if (widget.playlist.tracks.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () => widget.onTrackSelected(widget.playlist.tracks.first),
                      icon: const Icon(Icons.play_arrow_rounded, color: AppColors.black, size: 24),
                      label: const Text(
                        'Бүгдийг тоглуулах',
                        style: TextStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                      ),
                    ),
                  if (widget.playlist.tracks.isNotEmpty)
                    const SizedBox(width: 16),
                  IconButton(
                    icon: Icon(
                      _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: _isLiked ? Colors.redAccent : AppColors.white,
                      size: 28,
                    ),
                    onPressed: _toggleLike,
                  ),
                  if (_likeCount > 0) ...[
                    const SizedBox(width: 4),
                    Text(
                      '$_likeCount',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Tracks List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            sliver: widget.playlist.tracks.isEmpty
                ? const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Жагсаалт хоосон байна.',
                        style: TextStyle(color: AppColors.textTertiary),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final track = widget.playlist.tracks[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TrackTile(
                            title: track.title,
                            subtitle: track.artist,
                            gradientColors: track.gradientColors,
                            imagePath: track.imagePath,
                            onTap: () => widget.onTrackSelected(track),
                          ),
                        );
                      },
                      childCount: widget.playlist.tracks.length,
                    ),
                  ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 120),
          ),
        ],
      ),
    );
  }
}
