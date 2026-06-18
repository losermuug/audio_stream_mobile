import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streaming_app/shared/theme/colors.dart';
import 'package:streaming_app/features/home/domain/track.dart';
import 'package:streaming_app/features/home/presentation/widgets/custom_slider.dart';
import 'package:streaming_app/features/home/presentation/widgets/control_button.dart';
import 'package:streaming_app/shared/services/audio_player_service.dart';
import 'package:streaming_app/features/library/data/datasources/library_remote_data_source.dart';
import 'package:streaming_app/features/library/data/repositories/library_repository_impl.dart';
import 'package:streaming_app/features/library/domain/repositories/library_repository.dart';
import 'package:streaming_app/shared/services/api_client.dart';
import 'package:streaming_app/shared/services/auth_session.dart';
import 'package:streaming_app/features/home/domain/playlist.dart';
import 'package:streaming_app/shared/bloc/player/player_bloc.dart';
import 'package:streaming_app/shared/bloc/player/player_event.dart';
import 'package:streaming_app/shared/bloc/player/player_state.dart';
import 'package:streaming_app/shared/widgets/custom_toast.dart';

class NowPlayingScreen extends StatefulWidget {
  final double statusBarHeight;
  final void Function(Track track)? onLikeTap;

  const NowPlayingScreen({
    super.key,
    required this.statusBarHeight,
    this.onLikeTap,
  });

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  double _volume = 0.7;
  final _audioService = AudioPlayerService();

  @override
  void initState() {
    super.initState();
    _volume = _audioService.player.volume;
  }

  Duration _parseDuration(String durationStr) {
    final parts = durationStr.split(':');
    if (parts.length == 2) {
      final mins = int.tryParse(parts[0]) ?? 0;
      final secs = int.tryParse(parts[1]) ?? 0;
      return Duration(minutes: mins, seconds: secs);
    }
    if (durationStr.contains('мин') || durationStr.contains('ц')) {
      return const Duration(minutes: 45);
    }
    return const Duration(minutes: 3, seconds: 30);
  }

  String _formatDuration(Duration duration) {
    final twoDigitSeconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${duration.inMinutes}:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        final track = state.currentTrack;
        if (track == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pop();
          });
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.white),
            ),
          );
        }

        final isPlaying = state.isPlaying;
        final progress = state.progress;
        final currentDuration = state.position;
        final totalDuration = state.duration != Duration.zero
            ? state.duration
            : _parseDuration(track.duration);
        final remainingDuration = totalDuration - currentDuration;

        final primaryGlowColor = track.gradientColors.isNotEmpty
            ? track.gradientColors.first
            : AppColors.glow;

        final hasImage = track.imagePath != null;
        final isLiked = track.isLiked;
        final isShuffleActive = state.isShuffleEnabled;
        final isRepeatActive = state.isRepeatEnabled;

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Positioned.fill(
                child: hasImage
                    ? Image(
                        image: AudioPlayerService.getImageProvider(track.imagePath),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.black,
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: track.gradientColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.55),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: widget.statusBarHeight > 0 ? widget.statusBarHeight : 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppColors.iconDefault,
                                size: 32,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            const Column(
                              children: [
                                Text(
                                  'ОДОО ТОГЛОГДОЖ БУЙ',
                                  style: TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.more_horiz_rounded,
                                color: AppColors.iconDefault,
                                size: 24,
                              ),
                              onPressed: () => _showMoreOptionsBottomSheet(context, track),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryGlowColor.withValues(
                                    alpha: isPlaying ? 0.35 : 0.15,
                                  ),
                                  blurRadius: isPlaying ? 32 : 18,
                                  spreadRadius: isPlaying ? 4 : 1,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: hasImage
                                  ? Image(
                                      image: AudioPlayerService.getImageProvider(track.imagePath),
                                      fit: BoxFit.cover,
                                      width: 280,
                                      height: 280,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: track.gradientColors,
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.music_note_rounded,
                                            color: AppColors.white,
                                            size: 48,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: track.gradientColors,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.music_note_rounded,
                                          color: AppColors.white,
                                          size: 72,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      track.title,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      track.artist,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  isLiked
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: isLiked ? Colors.red : AppColors.iconDefault,
                                  size: 28,
                                ),
                                onPressed: () {
                                  widget.onLikeTap?.call(track);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          CustomSlider(
                            value: progress,
                            onChanged: (val) {
                              if (state.duration.inMilliseconds > 0) {
                                final targetMs = (val * state.duration.inMilliseconds).round();
                                context.read<PlayerBloc>().add(SeekEvent(Duration(milliseconds: targetMs)));
                              }
                            },
                            trackHeight: 4,
                            thumbRadius: 6,
                            overlayRadius: 12,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(currentDuration),
                                  style: const TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '-${_formatDuration(remainingDuration)}',
                                  style: const TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ControlButton(
                            icon: Icons.shuffle_rounded,
                            size: 22,
                            isActive: isShuffleActive,
                            inactiveColor: Colors.white.withValues(alpha: 0.35),
                            onTap: () {
                              context.read<PlayerBloc>().add(const ToggleShuffleEvent());
                            },
                          ),
                          ControlButton(
                            icon: Icons.skip_previous_rounded,
                            size: 34,
                            onTap: () {
                              context.read<PlayerBloc>().add(const PreviousTrackEvent());
                            },
                          ),
                          GestureDetector(
                            onTap: () {
                              context.read<PlayerBloc>().add(const TogglePlayPauseEvent());
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.white.withValues(
                                      alpha: isPlaying ? 0.35 : 0.1,
                                    ),
                                    blurRadius: isPlaying ? 24 : 12,
                                    spreadRadius: isPlaying ? 2 : 0,
                                  ),
                                ],
                              ),
                              child: Icon(
                                isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.black,
                                size: 40,
                              ),
                            ),
                          ),
                          ControlButton(
                            icon: Icons.skip_next_rounded,
                            size: 34,
                            onTap: () {
                              context.read<PlayerBloc>().add(const NextTrackEvent());
                            },
                          ),
                          ControlButton(
                            icon: Icons.repeat_rounded,
                            size: 22,
                            isActive: isRepeatActive,
                            inactiveColor: Colors.white.withValues(alpha: 0.35),
                            onTap: () {
                              context.read<PlayerBloc>().add(const ToggleRepeatEvent());
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Row(
                          children: [
                            Icon(
                              Icons.volume_mute_rounded,
                              color: Colors.white.withValues(alpha: 0.35),
                              size: 20,
                            ),
                            Expanded(
                              child: CustomSlider(
                                value: _volume,
                                onChanged: (val) {
                                  setState(() {
                                    _volume = val;
                                  });
                                  AudioPlayerService().setVolume(val);
                                },
                                trackHeight: 3,
                                thumbRadius: 4,
                                overlayRadius: 8,
                                activeTrackColor: AppColors.white.withValues(alpha: 0.6),
                                inactiveTrackColor: AppColors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            Icon(
                              Icons.volume_up_rounded,
                              color: Colors.white.withValues(alpha: 0.35),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMoreOptionsBottomSheet(BuildContext context, Track track) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.blackElevated.withValues(alpha: 0.8),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(
                color: AppColors.borderSubtle.withValues(alpha: 0.3),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey700,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.playlist_add_rounded, color: AppColors.white),
                    title: const Text(
                      'Тоглуулах жагсаалтад нэмэх',
                      style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showAddToPlaylistBottomSheet(context, track);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    title: const Text(
                      'Хаах',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddToPlaylistBottomSheet(BuildContext context, Track track) {
    if (!AuthSession().isAuthenticated) {
      CustomToast.show(
        context,
        'Энэ үйлдлийг хийхийн тулд нэвтрэх шаардлагатай.',
        isError: true,
      );
      return;
    }

    final LibraryRepository libraryRepository = LibraryRepositoryImpl(
      remoteDataSource: LibraryRemoteDataSource(
        client: ApiClient(),
      ),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: BoxDecoration(
              color: AppColors.blackElevated.withValues(alpha: 0.8),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(
                color: AppColors.borderSubtle.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey700,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Жагсаалтад нэмэх',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: FutureBuilder<List<Playlist>>(
                    future: libraryRepository.getMyPlaylists(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppColors.white),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Алдаа: ${snapshot.error}',
                            style: const TextStyle(color: AppColors.error),
                          ),
                        );
                      }
                      final playlists = snapshot.data ?? [];
                      if (playlists.isEmpty) {
                        return const Center(
                          child: Text(
                            'Жагсаалт одоогоор алга.',
                            style: TextStyle(color: AppColors.textTertiary),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: playlists.length,
                        itemBuilder: (context, index) {
                          final playlist = playlists[index];
                          return ListTile(
                            leading: const Icon(Icons.playlist_play_rounded, color: AppColors.white),
                            title: Text(
                              playlist.name,
                              style: const TextStyle(color: AppColors.white),
                            ),
                            subtitle: Text(
                              '${playlist.tracks.length} дуу',
                              style: const TextStyle(color: AppColors.textTertiary),
                            ),
                            onTap: () async {
                              try {
                                await libraryRepository.addTrackToPlaylist(
                                  playlistId: playlist.id,
                                  trackId: track.id,
                                );
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  CustomToast.show(
                                    context,
                                    '"${track.title}" дууг "${playlist.name}" жагсаалтад нэмлээ!',
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  CustomToast.show(
                                    context,
                                    'Нэмэхэд алдаа гарлаа: $e',
                                    isError: true,
                                  );
                                }
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
