import 'dart:async';
import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';
import 'package:streaming_app/features/home/domain/track.dart';
import 'package:streaming_app/features/home/domain/playlist.dart';
import 'package:streaming_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:streaming_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:streaming_app/features/home/domain/repositories/home_repository.dart';
import 'package:streaming_app/shared/services/api_client.dart';
import 'package:streaming_app/shared/services/auth_session.dart';
import 'package:streaming_app/features/home/presentation/widgets/hero_banner.dart';
import 'package:streaming_app/features/home/presentation/widgets/track_tile.dart';
import 'package:streaming_app/features/home/presentation/widgets/mini_player.dart';
import 'package:streaming_app/features/home/presentation/widgets/custom_bottom_nav.dart';
import 'package:streaming_app/features/home/presentation/widgets/section_header.dart';

import 'package:streaming_app/shared/widgets/gradient_album_art.dart';
import 'package:streaming_app/shared/widgets/custom_toast.dart';
import 'package:streaming_app/features/search/presentation/pages/search_screen.dart';
import 'package:streaming_app/features/home/presentation/pages/now_playing_screen.dart';
import 'package:streaming_app/features/profile/presentation/pages/profile_screen.dart';
import 'package:streaming_app/features/library/presentation/pages/library_screen.dart';
import 'package:streaming_app/shared/services/audio_player_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streaming_app/shared/bloc/player/player_bloc.dart';
import 'package:streaming_app/shared/bloc/player/player_event.dart';
import 'package:streaming_app/shared/bloc/player/player_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {

  int _currentTabIndex = 0;

  // Global playback state managed by AudioPlayerService
  Track _currentTrack = const Track(
    id: '',
    title: 'Сонсох дуу сонгоно уу',
    artist: '',
    duration: '0:00',
    gradientColors: [Color(0xFF1E1E1E), Color(0xFF3A3A3A)],
  );
  bool _isPlaying = false;
  double _progress = 0.0;
  bool _isMiniPlayerDismissed = false;

  final AudioPlayerService _audioService = AudioPlayerService();

  StateSetter? _nowPlayingStateSetter;
  bool _isNowPlayingOpen = false;

  final List<Track> _playlist = [];
  List<Track> _tracks = [];
  List<Playlist> _playlists = [];
  Track? _heroTrack;
  bool _isLoading = true;

  late final HomeRepository _homeRepository;

  // ── Staggered section entrance animations ──
  late final AnimationController _staggerController;
  late final List<Animation<double>> _sectionFades;
  late final List<Animation<Offset>> _sectionSlides;

  static const int _sectionCount = 5;

  @override
  void initState() {
    super.initState();

    _homeRepository = HomeRepositoryImpl(
      remoteDataSource: HomeRemoteDataSource(
        client: ApiClient(),
      ),
    );

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _sectionFades = List.generate(_sectionCount, (i) {
      final start = (i * 0.15).clamp(0.0, 0.8);
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _sectionSlides = List.generate(_sectionCount, (i) {
      final start = (i * 0.15).clamp(0.0, 0.8);
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _staggerController.forward();
    _loadBackendFeed();
  }

  Future<void> _loadBackendFeed() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final tracks = await _homeRepository.getTracks();
      final playlists = await _homeRepository.getPlaylists();
      setState(() {
        _tracks = tracks;
        _playlists = playlists;
        
        _playlist.clear();
        _playlist.addAll(tracks);

        if (tracks.isNotEmpty) {
          _heroTrack = tracks.first;
          _currentTrack = tracks.first;
        }
      });
    } catch (e) {
      debugPrint('Failed to load database feed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Өглөөний мэнд';
    } else if (hour >= 12 && hour < 18) {
      return 'Өдрийн мэнд';
    } else {
      return 'Оройн мэнд';
    }
  }

  void _onTrackSelected(Track track) {
    setState(() {
      _currentTrack = track;
      _progress = 0.0;
      _isMiniPlayerDismissed = false;
    });
    
    // Play track via PlayerBloc to manage queue and current track state
    final queue = _playlist.isNotEmpty ? _playlist : [track];
    context.read<PlayerBloc>().add(PlayTrackEvent(track: track, queue: queue));

    _nowPlayingStateSetter?.call(() {});
    _showNowPlaying(track);
  }

  void _togglePlayback() {
    context.read<PlayerBloc>().add(const TogglePlayPauseEvent());
  }

  void _showNowPlaying(Track track) {
    if (_isNowPlayingOpen) {
      return;
    }

    _isNowPlayingOpen = true;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return NowPlayingScreen(
          statusBarHeight: statusBarHeight,
          onLikeTap: (t) {
            _toggleLikeTrack(t);
          },
        );
      },
    ).then((_) {
      _isNowPlayingOpen = false;
    });
  }

  void _updateTrackInState(Track updatedTrack) {
    if (!mounted) return;
    setState(() {
      if (_currentTrack.id == updatedTrack.id) {
        _currentTrack = updatedTrack;
      }
      if (_heroTrack?.id == updatedTrack.id) {
        _heroTrack = updatedTrack;
      }
      
      // Update in tracks list
      for (int i = 0; i < _tracks.length; i++) {
        if (_tracks[i].id == updatedTrack.id) {
          _tracks[i] = updatedTrack;
        }
      }
      
      // Update in playlist list
      for (int i = 0; i < _playlist.length; i++) {
        if (_playlist[i].id == updatedTrack.id) {
          _playlist[i] = updatedTrack;
        }
      }

      // Also update inside playlists list if needed
      for (var playlist in _playlists) {
        for (int i = 0; i < playlist.tracks.length; i++) {
          if (playlist.tracks[i].id == updatedTrack.id) {
            playlist.tracks[i] = updatedTrack;
          }
        }
      }
    });

    // Refresh the bottom sheet UI
    _nowPlayingStateSetter?.call(() {});

    // Also notify PlayerBloc
    context.read<PlayerBloc>().add(UpdateTrackEvent(updatedTrack));
  }

  Future<void> _toggleLikeTrack(Track track) async {
    if (!AuthSession().isAuthenticated) {
      if (mounted) {
        CustomToast.show(
          context,
          'Дууг таалагдсан болгохын тулд нэвтрэх шаардлагатай.',
          isError: true,
        );
      }
      return;
    }

    final bool nextLiked = !track.isLiked;
    final updatedTrack = track.copyWith(isLiked: nextLiked);
    
    // Apply optimistic update
    _updateTrackInState(updatedTrack);

    try {
      bool success;
      if (nextLiked) {
        success = await _homeRepository.likeTrack(track.id);
      } else {
        success = await _homeRepository.unlikeTrack(track.id);
      }

      if (!success) {
        throw Exception('Server returned false');
      }
    } catch (e) {
      // Revert on error
      debugPrint('Failed to sync like status: $e');
      _updateTrackInState(track);
      
      if (mounted) {
        CustomToast.show(
          context,
          nextLiked
              ? 'Дууг таалагдсан болгоход алдаа гарлаа: $e'
              : 'Дууг таалагдсанаас хасахад алдаа гарлаа: $e',
          isError: true,
        );
      }
    }
  }

  // ─────────────────────────────────────────────
  //  Wrap a child in stagger animation
  // ─────────────────────────────────────────────
  Widget _staggered(int index, Widget child) {
    final clampedIndex = index.clamp(0, _sectionCount - 1);
    return SlideTransition(
      position: _sectionSlides[clampedIndex],
      child: FadeTransition(
        opacity: _sectionFades[clampedIndex],
        child: child,
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentTabIndex) {
      case 0:
        if (_isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.white,
            ),
          );
        }
        return CustomScrollView(
          key: const ValueKey('home_feed'),
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, bottom: 160),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _staggered(0, _buildHeader()),
                    const SizedBox(height: 20),
                    if (_heroTrack != null)
                      _staggered(
                        1,
                        HeroBanner(
                          title: _heroTrack!.title,
                          subtitle: _heroTrack!.artist,
                          followersText: '4.2M Дагагчтай сонсож байна',
                          badgeText: 'онцлох дуу',
                          gradientColors: _heroTrack!.gradientColors,
                          imagePath: _heroTrack!.imagePath,
                          onPlayTap: () =>
                              _onTrackSelected(_heroTrack!),
                        ),
                      ),
                    if (_tracks.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _staggered(2, _buildRecentlyPlayed()),
                      const SizedBox(height: 24),
                      _staggered(3, _buildRecommendations()),
                    ],
                    if (_playlists.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _staggered(4, _buildFeaturedPlaylists()),
                    ],
                    if (_tracks.isEmpty && _playlists.isEmpty) ...[
                      const SizedBox(height: 60),
                      Center(
                        child: Text(
                          'Өгөгдлийн сан хоосон байна.\nДуу оруулж эхэлнэ үү.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textTertiary.withValues(alpha: 0.8),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        );
      case 1:
        return SearchScreen(
          key: const ValueKey('search_tab'),
          onTrackSelected: _onTrackSelected,
        );
      case 2:
        return LibraryScreen(
          key: const ValueKey('library_tab'),
          onTrackSelected: _onTrackSelected,
        );
      case 3:
        return ProfileScreen(
          key: const ValueKey('profile_tab'),
          onTrackUploaded: (newTrack) {
            _loadBackendFeed();
            CustomToast.show(
              context,
              '"${newTrack.title}" амжилттай цацагдлаа. Сүүлд сонссон жагсаалтад нэмэгдлээ!',
            );
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double systemBottom = MediaQuery.of(context).padding.bottom;
    // Tighter bottom spacing: ~22px on notch devices (systemBottom - 12)
    // and 10px on standard bezel devices, keeping it floating but closer to the bottom.
    final double bottomGap = systemBottom > 0 ? (systemBottom - 12) : 10;

    return BlocListener<PlayerBloc, PlayerState>(
      listener: (context, state) {
        if (state.currentTrack != null && state.currentTrack != _currentTrack) {
          setState(() {
            _currentTrack = state.currentTrack!;
            _isMiniPlayerDismissed = false;
          });
        }
        if (state.isPlaying != _isPlaying) {
          setState(() {
            _isPlaying = state.isPlaying;
          });
        }
        if (state.progress != _progress) {
          setState(() {
            _progress = state.progress;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // ── Tab Body with cross-fade animation ──
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  child: _buildBody(),
                ),
              ),

              // ── Persistent Floating Mini Player + Bottom Nav ──
              Positioned(
                left: 12,
                right: 12,
                bottom: bottomGap,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mini Player (floating card)
                    if (!_isMiniPlayerDismissed && _currentTrack.id.isNotEmpty)
                      Dismissible(
                        key: Key('mini_player_${_currentTrack.id}'),
                        direction: DismissDirection.horizontal,
                        onDismissed: (direction) {
                          setState(() {
                            _isMiniPlayerDismissed = true;
                          });
                          _audioService.pause();
                          CustomToast.show(
                            context,
                            'Тоглуулагчийг хаалаа',
                          );
                        },
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.close_rounded, color: AppColors.white),
                        ),
                        secondaryBackground: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.close_rounded, color: AppColors.white),
                        ),
                        child: MiniPlayer(
                          title: _currentTrack.title,
                          artist: _currentTrack.artist,
                          gradientColors: _currentTrack.gradientColors,
                          isPlaying: _isPlaying,
                          progress: _progress,
                          onPlayPauseTap: _togglePlayback,
                          isLiked: _currentTrack.isLiked,
                          onLikeTap: () => _toggleLikeTrack(_currentTrack),
                          imagePath: _currentTrack.imagePath,
                          onTap: () => _showNowPlaying(_currentTrack),
                        ),
                      ),
                    const SizedBox(height: 8),
                    // Bottom Navigation (floating pill)
                    CustomBottomNav(
                      currentIndex: _currentTabIndex,
                      onTap: (index) {
                        setState(() {
                          _currentTabIndex = index;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  HEADER — Greeting + Avatar + Notification
  // ─────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Мөнхзул',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        // Notification button
        GestureDetector(
          onTap: () {
            CustomToast.show(
              context,
              'Шинэ мэдэгдэл байхгүй байна.',
            );
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.grey800,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.grey400,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }


  // _buildSectionHeader extracted to SectionHeader widget in shared/widgets/section_header.dart

  Widget _buildRecentlyPlayed() {
    if (_tracks.isEmpty) return const SizedBox.shrink();
    final list = _tracks.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Сүүлд сонссон',
          onSeeAllTap: () => CustomToast.show(
            context,
            'Сүүлд сонссон — удахгүй...',
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.6,
          ),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final track = list[index];

            return GestureDetector(
              onTap: () => _onTrackSelected(track),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.grey900,
                  borderRadius: BorderRadius.circular(10),
                ),
                clipBehavior: Clip.antiAlias,
                child: Row(
                  children: [
                    // Gradient Cover
                    GradientAlbumArt(
                      size: 54,
                      borderRadius: 0,
                      gradientColors: track.gradientColors,
                      iconSize: 20,
                      imagePath: track.imagePath,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            track.artist,
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecommendations() {
    if (_tracks.isEmpty) return const SizedBox.shrink();
    final list = _tracks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Танд зориулсан хэмнэл',
          onSeeAllTap: () => CustomToast.show(
            context,
            'Танд зориулсан хэмнэл — удахгүй...',
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final track = list[index];

              return TrackTile(
                title: track.title,
                subtitle: track.artist,
                gradientColors: track.gradientColors,
                isGridStyle: true,
                imagePath: track.imagePath,
                onTap: () => _onTrackSelected(track),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedPlaylists() {
    if (_playlists.isEmpty) return const SizedBox.shrink();
    final list = _playlists;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Шилдэг тоглуулах жагсаалт',
          onSeeAllTap: () => CustomToast.show(
            context,
            'Шилдэг тоглуулах жагсаалт — удахгүй...',
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final playlist = list[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TrackTile(
                title: playlist.name,
                subtitle: playlist.description ?? '${playlist.tracks.length} дуу',
                duration: '${playlist.tracks.length} дуу',
                gradientColors: const [Color(0xFF2C3E50), Color(0xFFFD746C)],
                defaultIcon: Icons.playlist_play_rounded,
                imagePath: playlist.coverUrl,
                onTap: () {
                  if (playlist.tracks.isNotEmpty) {
                    setState(() {
                      _playlist.clear();
                      _playlist.addAll(playlist.tracks);
                    });
                    _onTrackSelected(playlist.tracks.first);
                  } else {
                    CustomToast.show(
                      context,
                      '${playlist.name} жагсаалт хоосон байна',
                      isError: true,
                    );
                  }
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
