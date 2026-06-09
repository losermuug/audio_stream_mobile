
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';
import 'package:streaming_app/features/home/domain/track.dart';
import 'package:streaming_app/features/home/presentation/widgets/hero_banner.dart';
import 'package:streaming_app/features/home/presentation/widgets/track_tile.dart';
import 'package:streaming_app/features/home/presentation/widgets/mini_player.dart';
import 'package:streaming_app/features/home/presentation/widgets/custom_bottom_nav.dart';
import 'package:streaming_app/features/home/presentation/widgets/section_header.dart';

import 'package:streaming_app/shared/widgets/gradient_album_art.dart';
import 'package:streaming_app/features/search/presentation/pages/search_screen.dart';
import 'package:streaming_app/features/home/presentation/pages/now_playing_screen.dart';
import 'package:streaming_app/features/profile/presentation/pages/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {

  int _currentTabIndex = 0;

  // Global playback state managed directly inside HomeScreen
  Track _currentTrack = MockData.featuredHero;
  bool _isPlaying = false;
  double _progress = 0.35;

  Timer? _progressTimer;
  StateSetter? _nowPlayingStateSetter;
  bool _isNowPlayingOpen = false;

  final List<Track> _playlist = [
    MockData.featuredHero,
    ...MockData.recentlyPlayed,
    ...MockData.recommended,
  ];

  // ── Staggered section entrance animations ──
  late final AnimationController _staggerController;
  late final List<Animation<double>> _sectionFades;
  late final List<Animation<Offset>> _sectionSlides;

  static const int _sectionCount = 5; // header, hero, chips, recent, reco, playlists → grouped

  @override
  void initState() {
    super.initState();

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
    _startProgressTimer();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _progressTimer?.cancel();
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

  Duration _parseDuration(String durationStr) {
    final parts = durationStr.split(':');
    if (parts.length == 2) {
      final mins = int.tryParse(parts[0]) ?? 0;
      final secs = int.tryParse(parts[1]) ?? 0;
      return Duration(minutes: mins, seconds: secs);
    }
    return const Duration(minutes: 3, seconds: 30);
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPlaying) {
        setState(() {
          final totalSecs = _parseDuration(_currentTrack.duration).inSeconds;
          if (totalSecs > 0) {
            _progress = (_progress + 1 / totalSecs).clamp(0.0, 1.0);
            if (_progress >= 1.0) {
              _progress = 0.0;
              _playNextTrack();
            }
          }
        });
        _nowPlayingStateSetter?.call(() {});
      }
    });
  }

  void _playNextTrack() {
    final currentIndex = _playlist.indexWhere((t) => t.id == _currentTrack.id);
    if (currentIndex != -1 && currentIndex < _playlist.length - 1) {
      _onTrackSelected(_playlist[currentIndex + 1]);
    } else {
      _onTrackSelected(_playlist.first);
    }
  }

  void _playPreviousTrack() {
    final currentIndex = _playlist.indexWhere((t) => t.id == _currentTrack.id);
    if (currentIndex != -1 && currentIndex > 0) {
      _onTrackSelected(_playlist[currentIndex - 1]);
    } else {
      _onTrackSelected(_playlist.last);
    }
  }

  void _onTrackSelected(Track track) {
    setState(() {
      _currentTrack = track;
      _isPlaying = true;
      _progress = 0.0;
    });
    _nowPlayingStateSetter?.call(() {});
    _showNowPlaying(track);
  }

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    _nowPlayingStateSetter?.call(() {});
  }

  void _showNowPlaying(Track track) {
    if (_isNowPlayingOpen) {
      _nowPlayingStateSetter?.call(() {});
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
        return StatefulBuilder(
          builder: (context, setSheetState) {
            _nowPlayingStateSetter = setSheetState;
            return NowPlayingScreen(
              track: _currentTrack,
              isPlaying: _isPlaying,
              progress: _progress,
              statusBarHeight: statusBarHeight,
              onPlayPauseTap: () {
                _togglePlayback();
                setSheetState(() {});
              },
              onProgressChanged: (val) {
                setState(() {
                  _progress = val;
                });
                setSheetState(() {});
              },
              onNextTap: () {
                _playNextTrack();
                setSheetState(() {});
              },
              onPreviousTap: () {
                _playPreviousTrack();
                setSheetState(() {});
              },
              onLikeTap: () {
                // Toggle like status or update state
              },
            );
          },
        );
      },
    ).then((_) {
      _isNowPlayingOpen = false;
      _nowPlayingStateSetter = null;
    });
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

  Widget _buildEmptyTab(String title, IconData icon, Key key) {
    return Center(
      key: key,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppColors.iconMuted.withValues(alpha: 0.3),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textTertiary.withValues(alpha: 0.6),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Одоогоор хоосон байна',
            style: TextStyle(
              color: AppColors.textTertiary.withValues(alpha: 0.4),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 120), // Compensate for bottom floating player/navbar height
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentTabIndex) {
      case 0:
        return CustomScrollView(
          key: const ValueKey('home_feed'),
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 24, right: 24, bottom: 160),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _staggered(0, _buildHeader()),
                    const SizedBox(height: 28),
                    _staggered(
                      1,
                      HeroBanner(
                        title: MockData.featuredHero.title,
                        subtitle: MockData.featuredHero.artist,
                        followersText: '4.2M Дагагчтай сонсож байна',
                        badgeText: 'онцлох дуу',
                        gradientColors:
                            MockData.featuredHero.gradientColors,
                        imagePath: MockData.featuredHero.imagePath,
                        onPlayTap: () =>
                            _onTrackSelected(MockData.featuredHero),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _staggered(3, _buildRecentlyPlayed()),
                    const SizedBox(height: 32),
                    _staggered(4, _buildRecommendations()),
                    const SizedBox(height: 32),
                    _staggered(4, _buildFeaturedPlaylists()),
                    const SizedBox(height: 32),
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
        return _buildEmptyTab(
          'Сан',
          Icons.library_music_rounded,
          const ValueKey('library_tab'),
        );
      case 3:
        return ProfileScreen(
          key: const ValueKey('profile_tab'),
          onTrackUploaded: (newTrack) {
            setState(() {
              _playlist.insert(1, newTrack);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '"${newTrack.title}" амжилттай цацагдлаа. Сүүлд сонссон жагсаалтад нэмэгдлээ!',
                  style: const TextStyle(color: AppColors.white),
                ),
                backgroundColor: AppColors.grey900,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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

    return Scaffold(
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
                  MiniPlayer(
                    title: _currentTrack.title,
                    artist: _currentTrack.artist,
                    gradientColors: _currentTrack.gradientColors,
                    isPlaying: _isPlaying,
                    progress: _progress,
                    onPlayPauseTap: _togglePlayback,
                    imagePath: _currentTrack.imagePath,
                    onTap: () => _showNowPlaying(_currentTrack),
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
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Мөнхзул',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        // Action buttons
        Row(
          children: [
            // Notification bell with dot indicator
            Stack(
              children: [
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Танд одоогоор мэдэгдэл байхгүй байна.'),
                        backgroundColor: AppColors.grey900,
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.iconDefault,
                    size: 22,
                  ),
                ),
                // Notification badge dot
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.error.withValues(alpha: 0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            // Avatar with gradient ring
            GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/', (route) => false);
              },
              child: Container(
                width: 42,
                height: 42,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.grey500,
                      AppColors.white.withValues(alpha: 0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.grey900,
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }


  // _buildSectionHeader extracted to SectionHeader widget in shared/widgets/section_header.dart

  // ─────────────────────────────────────────────
  //  RECENTLY PLAYED — Enhanced grid with glow
  // ─────────────────────────────────────────────

  Widget _buildRecentlyPlayed() {
    final list = MockData.recentlyPlayed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Сүүлд сонссон',
          onSeeAllTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Сүүлд сонссон — удахгүй...'),
              backgroundColor: AppColors.grey900,
              duration: Duration(milliseconds: 800),
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.6,
          ),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final track = list[index];
            final glowColor = track.gradientColors.isNotEmpty
                ? track.gradientColors.first
                : AppColors.glow;

            return GestureDetector(
              onTap: () => _onTrackSelected(track),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.borderSubtle.withValues(alpha: 0.6),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withValues(alpha: 0.08),
                      blurRadius: 12,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Row(
                  children: [
                    // Gradient Cover
                    GradientAlbumArt(
                      size: 58,
                      borderRadius: 0,
                      gradientColors: track.gradientColors,
                      iconSize: 22,
                      imagePath: track.imagePath,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            track.artist,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
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

  // ─────────────────────────────────────────────
  //  RECOMMENDATIONS — Horizontal cards
  // ─────────────────────────────────────────────

  Widget _buildRecommendations() {
    final list = MockData.recommended;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Танд зориулсан хэмнэл',
          onSeeAllTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Танд зориулсан хэмнэл — удахгүй...'),
              backgroundColor: AppColors.grey900,
              duration: Duration(milliseconds: 800),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240, // Increased for new 160px TrackTile cards
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

  // ─────────────────────────────────────────────
  //  FEATURED PLAYLISTS
  // ─────────────────────────────────────────────

  Widget _buildFeaturedPlaylists() {
    final list = MockData.featuredPlaylists;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Шилдэг тоглуулах жагсаалт',
          onSeeAllTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Шилдэг тоглуулах жагсаалт — удахгүй...'),
              backgroundColor: AppColors.grey900,
              duration: Duration(milliseconds: 800),
            ),
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
                title: playlist.title,
                subtitle: playlist.artist,
                duration: playlist.duration,
                gradientColors: playlist.gradientColors,
                defaultIcon: Icons.playlist_play_rounded,
                imagePath: playlist.imagePath,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('${playlist.title} жагсаалтыг сонслоо'),
                      backgroundColor: AppColors.grey900,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
