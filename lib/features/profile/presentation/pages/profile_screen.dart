import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';
import 'package:streaming_app/shared/theme/typography.dart';
import 'package:streaming_app/features/home/domain/track.dart';
import 'package:streaming_app/features/profile/presentation/pages/publish_song_screen.dart';
import 'package:streaming_app/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:streaming_app/features/profile/presentation/pages/change_password_screen.dart';
import 'package:streaming_app/features/profile/presentation/widgets/user_identity_card.dart';
import 'package:streaming_app/features/profile/presentation/widgets/setting_tile.dart';
import 'package:streaming_app/shared/services/auth_session.dart';

// Dynamically fetch stats
import 'package:streaming_app/features/library/data/repositories/library_repository_impl.dart';
import 'package:streaming_app/features/library/data/datasources/library_remote_data_source.dart';
import 'package:streaming_app/shared/services/api_client.dart';

class ProfileScreen extends StatefulWidget {
  final Function(Track)? onTrackUploaded;

  const ProfileScreen({
    super.key,
    this.onTrackUploaded,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _likedCount = 0;
  int _playlistCount = 0;
  int _listenedCount = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (!mounted) return;
    setState(() => _isLoadingStats = true);
    try {
      final libraryRepo = LibraryRepositoryImpl(
        remoteDataSource: LibraryRemoteDataSource(
          client: ApiClient(),
        ),
      );
      final likedTracks = await libraryRepo.getLikedTracks();
      final playlists = await libraryRepo.getMyPlaylists();
      final listenedCount = await libraryRepo.getPlayHistoryCount();

      if (mounted) {
        setState(() {
          _likedCount = likedTracks.length;
          _playlistCount = playlists.length;
          _listenedCount = listenedCount;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load profile stats: $e');
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.black.withValues(alpha: 0.7),
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.modalBackground.withValues(alpha: 0.95),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                border: Border.all(
                  color: AppColors.borderSubtle.withValues(alpha: 0.6),
                  width: 0.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey700,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Системээс гарах уу?',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Та системээс гарахдаа итгэлтэй байна уу?',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(
                                color: AppColors.borderStrong,
                                width: 1,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Үгүй',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await AuthSession().clearSession();
                            if (context.mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/',
                                (route) => false,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.white,
                            foregroundColor: AppColors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Гарах',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String sessionName = AuthSession().userName ?? 'Хэрэглэгч';
    final String? sessionEmail = AuthSession().userEmail;
    String sessionRole = 'Сонсогч';
    if (AuthSession().userRole == 'artist') {
      sessionRole = 'Уран бүтээлч';
    } else if (AuthSession().userRole == 'admin') {
      sessionRole = 'Админ';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadStats,
        color: AppColors.white,
        backgroundColor: AppColors.cardBackground,
        child: CustomScrollView(
          key: const ValueKey('profile_scroll'),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              centerTitle: false,
              titleSpacing: 20,
              automaticallyImplyLeading: false,
              title: const Text(
                'Профайл',
                style: AppTypography.screenTitle,
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 160),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // ── User Identity Section ──
                    UserIdentityCard(
                      userName: sessionName,
                      userRole: sessionRole,
                      userEmail: sessionEmail,
                      avatarAsset: 'assets/image/avatar_user.png',
                      likedCount: _likedCount,
                      playlistCount: _playlistCount,
                      listenedCount: _listenedCount,
                      isLoading: _isLoadingStats,
                    ),
                    const SizedBox(height: 36),

                    // ── Account Section ──
                    _buildSectionTitle('БҮРТГЭЛ'),
                    const SizedBox(height: 12),
                    _buildSettingsGroup(context, [
                      SettingTile(
                        title: 'Хувийн мэдээлэл',
                        subtitle: sessionEmail ?? 'Хэрэглэгчийн мэдээлэл харах',
                        icon: Icons.person_outline_rounded,
                        first: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          ).then((updated) {
                            if (updated == true) {
                              setState(() {}); // refresh session details
                            }
                          });
                        },
                      ),
                      SettingTile(
                        title: 'Нууц үг солих',
                        subtitle: 'Нэвтрэх нууц үгээ шинэчлэх',
                        icon: Icons.lock_outline_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChangePasswordScreen(),
                            ),
                          );
                        },
                      ),
                      SettingTile(
                        title: 'Уран бүтээл цацах',
                        subtitle: AuthSession().userRole == 'artist' 
                            ? 'Шинэ дуу системд оруулах' 
                            : 'Уран бүтээлч эрхээр цацах',
                        icon: Icons.album_rounded,
                        last: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PublishSongScreen(
                                onTrackPublished: (track) {
                                  widget.onTrackUploaded?.call(track);
                                  _loadStats();
                                },
                              ),
                            ),
                          ).then((_) {
                            _loadStats();
                          });
                        },
                      ),
                    ]),
                    const SizedBox(height: 28),

                    // ── Preferences Section ──
                    _buildSectionTitle('ТОХИРГОО'),
                    const SizedBox(height: 12),
                    _buildSettingsGroup(context, [
                      const SettingTile(
                        title: 'Төхөөрөмжүүд',
                        subtitle: 'Холбогдсон төхөөрөмжүүдийг удирдах',
                        icon: Icons.devices_rounded,
                        trailingText: '1 идэвхтэй',
                        first: true,
                      ),
                      const SettingTile(
                        title: 'Мэдэгдэл',
                        subtitle: 'Шинэ уран бүтээл, мэдээллийн мэдэгдэл',
                        icon: Icons.notifications_none_rounded,
                        trailingText: 'Асаалттай',
                        last: true,
                      ),
                    ]),
                    const SizedBox(height: 36),

                    // ── Logout Button ──
                    _buildLogoutButton(context),
                    const SizedBox(height: 32),

                    // ── Version Info ──
                    const Center(
                      child: Text(
                        'Хувилбар 1.0.0',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  UI Widgets Builders
  // ──────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textTertiary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, List<Widget> tiles) {
    final List<Widget> children = [];
    for (int i = 0; i < tiles.length; i++) {
      children.add(tiles[i]);
      if (i < tiles.length - 1) {
        children.add(_buildDivider());
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderSubtle.withValues(alpha: 0.25),
          width: 0.5,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 56),
      height: 0.5,
      color: AppColors.divider.withValues(alpha: 0.3),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderSubtle.withValues(alpha: 0.25),
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLogoutConfirmation(context),
          borderRadius: BorderRadius.circular(16),
          splashColor: const Color(0xFFFF5252).withValues(alpha: 0.08),
          highlightColor: const Color(0xFFFF5252).withValues(alpha: 0.04),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFFF5252),
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Системээс гарах',
                  style: TextStyle(
                    color: Color(0xFFFF5252),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}