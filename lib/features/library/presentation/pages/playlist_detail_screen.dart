import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';
import 'package:streaming_app/features/home/domain/playlist.dart';
import 'package:streaming_app/features/home/domain/track.dart';
import 'package:streaming_app/features/home/presentation/widgets/track_tile.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final Playlist playlist;
  final void Function(Track track) onTrackSelected;

  const PlaylistDetailScreen({
    super.key,
    required this.playlist,
    required this.onTrackSelected,
  });

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
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E1E1E), Color(0xFF000000)],
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
                        playlist.name,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.8,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (playlist.description != null && playlist.description!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          playlist.description!,
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
                        '${playlist.tracks.length} дуу',
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
          
          // Play All Button Section
          if (playlist.tracks.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => onTrackSelected(playlist.tracks.first),
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
                  ],
                ),
              ),
            ),

          // Tracks List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            sliver: playlist.tracks.isEmpty
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
                        final track = playlist.tracks[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TrackTile(
                            title: track.title,
                            subtitle: track.artist,
                            gradientColors: track.gradientColors,
                            imagePath: track.imagePath,
                            onTap: () => onTrackSelected(track),
                          ),
                        );
                      },
                      childCount: playlist.tracks.length,
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
