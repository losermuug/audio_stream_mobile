import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';
import 'package:streaming_app/features/home/domain/track.dart';
import 'package:streaming_app/features/home/domain/playlist.dart';
import 'package:streaming_app/features/home/presentation/widgets/track_tile.dart';
import 'package:streaming_app/features/library/data/datasources/library_remote_data_source.dart';
import 'package:streaming_app/features/library/data/repositories/library_repository_impl.dart';
import 'package:streaming_app/features/library/domain/repositories/library_repository.dart';
import 'package:streaming_app/shared/services/api_client.dart';
import 'package:streaming_app/features/library/presentation/pages/playlist_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  final void Function(Track track) onTrackSelected;

  const LibraryScreen({super.key, required this.onTrackSelected});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late final LibraryRepository _libraryRepository;
  int _selectedTab = 0; // 0: Liked Songs, 1: Playlists
  List<Track> _likedTracks = [];
  List<Playlist> _playlists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _libraryRepository = LibraryRepositoryImpl(
      remoteDataSource: LibraryRemoteDataSource(
        client: ApiClient(),
      ),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      if (_selectedTab == 0) {
        final tracks = await _libraryRepository.getLikedTracks();
        setState(() {
          _likedTracks = tracks;
        });
      } else {
        final playlists = await _libraryRepository.getMyPlaylists();
        setState(() {
          _playlists = playlists;
        });
      }
    } catch (e) {
      debugPrint('Library load error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showCreatePlaylistDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = Curves.easeInOutBack.transform(anim1.value);
        return Transform.scale(
          scale: 0.85 + (curve * 0.15),
          child: Opacity(
            opacity: anim1.value,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: AlertDialog(
                backgroundColor: AppColors.blackElevated.withValues(alpha: 0.85),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: AppColors.borderSubtle.withValues(alpha: 0.8),
                  ),
                ),
                title: const Text(
                  'Шинэ тоглуулах жагсаалт',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: AppColors.white),
                      decoration: const InputDecoration(
                        hintText: 'Нэр',
                        hintStyle: TextStyle(color: AppColors.textPlaceholder),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descController,
                      style: const TextStyle(color: AppColors.white),
                      decoration: const InputDecoration(
                        hintText: 'Тайлбар (Заавал биш)',
                        hintStyle: TextStyle(color: AppColors.textPlaceholder),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Цуцлах',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final name = nameController.text.trim();
                      if (name.isNotEmpty) {
                        try {
                          await _libraryRepository.createPlaylist(
                            name: name,
                            description: descController.text.trim().isNotEmpty
                                ? descController.text.trim()
                                : null,
                          );
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                          _loadData();
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Жагсаалт үүсгэхэд алдаа гарлаа: $e'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      }
                    },
                    child: const Text(
                      'Үүсгэх',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabSelector() {
  return Container(
    height: 48,
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: AppColors.blackSurface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: AppColors.borderSubtle.withValues(alpha: 0.5),
      ),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final tabWidth = constraints.maxWidth / 2;
        return Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              left: _selectedTab == 0 ? 0 : tabWidth,
              top: 0,
              bottom: 0,
              width: tabWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (_selectedTab != 0) {
                        setState(() => _selectedTab = 0);
                        _loadData();
                      }
                    },
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        style: TextStyle(
                          color: _selectedTab == 0 ? AppColors.black : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        child: const Text('Дуртай дуунууд'),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (_selectedTab != 1) {
                        setState(() => _selectedTab = 1);
                        _loadData();
                      }
                    },
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        style: TextStyle(
                          color: _selectedTab == 1 ? AppColors.black : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        child: const Text('Миний жагсаалт'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.blackSurface,
              border: Border.all(
                color: AppColors.borderSubtle.withValues(alpha: 0.6),
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.textTertiary,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          if (_selectedTab == 1) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showCreatePlaylistDialog,
              icon: const Icon(Icons.add_rounded, color: AppColors.black),
              label: const Text(
                'Жагсаалт үүсгэх',
                style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildLikedSongsList() {
    if (_likedTracks.isEmpty) {
      return _buildEmptyState(
        'Таалагдсан дуунууд хараахан алга.',
        Icons.favorite_border_rounded,
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: _likedTracks.length,
      itemBuilder: (context, index) {
        final track = _likedTracks[index];
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
    );
  }

  Widget _buildPlaylistsGrid() {
    if (_playlists.isEmpty) {
      return _buildEmptyState(
        'Тоглуулах жагсаалт хоосон байна.',
        Icons.library_music_rounded,
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_playlists.length} Жагсаалт',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton.icon(
                onPressed: _showCreatePlaylistDialog,
                icon: const Icon(Icons.add_rounded, color: AppColors.white, size: 18),
                label: const Text(
                  'Үүсгэх',
                  style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.borderStrong),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 120),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: _playlists.length,
            itemBuilder: (context, index) {
              final playlist = _playlists[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PlaylistDetailScreen(
                        playlist: playlist,
                        onTrackSelected: widget.onTrackSelected,
                      ),
                    ),
                  ).then((_) => _loadData());
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.borderSubtle.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E1E1E), Color(0xFF3A3A3A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.playlist_play_rounded,
                              color: AppColors.white,
                              size: 48,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        playlist.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${playlist.tracks.length} дуу',
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Миний сан',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 16),
          _buildTabSelector(),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                    ),
                  )
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeInOutCubic,
                    switchOutCurve: Curves.easeInOutCubic,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      final isEntering = child.key == (_selectedTab == 0
                          ? const ValueKey('liked_songs_list')
                          : const ValueKey('playlists_grid'));
                      
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: isEntering
                              ? (_selectedTab == 0 ? const Offset(-0.06, 0.0) : const Offset(0.06, 0.0))
                              : (_selectedTab == 0 ? const Offset(0.06, 0.0) : const Offset(-0.06, 0.0)),
                          end: Offset.zero,
                        ).animate(animation),
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: _selectedTab == 0
                        ? KeyedSubtree(
                            key: const ValueKey('liked_songs_list'),
                            child: _buildLikedSongsList(),
                          )
                        : KeyedSubtree(
                            key: const ValueKey('playlists_grid'),
                            child: _buildPlaylistsGrid(),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
