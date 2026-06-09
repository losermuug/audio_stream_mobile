import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';
import 'package:streaming_app/features/home/domain/track.dart';
import 'package:streaming_app/features/profile/presentation/pages/publish_song_screen.dart';
import 'package:streaming_app/features/profile/presentation/widgets/user_identity_card.dart';
import 'package:streaming_app/features/profile/presentation/widgets/setting_tile.dart';

class ProfileScreen extends StatelessWidget {
  final Function(Track)? onTrackUploaded;

  const ProfileScreen({
    super.key,
    this.onTrackUploaded,
  });

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
                  const Icon(
                    Icons.logout_rounded,
                    color: AppColors.white,
                    size: 36,
                  ),
                  const SizedBox(height: 16),
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
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/',
                              (route) => false,
                            );
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        key: const ValueKey('profile_scroll'),
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            centerTitle: false,
            title: const Text(
              'Профайл',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: AppColors.white),
                onPressed: () {},
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 160),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // ── User Identity Section ──
                  const UserIdentityCard(
                    userName: 'Мөнхзул',
                    userRole: 'Premium сонсогч',
                    avatarAsset: 'assets/image/avatar_user.png',
                  ),
                  const SizedBox(height: 32),

                  // ── Settings List Section ──
                  _buildSectionTitle('Тохиргоо'),
                  const SizedBox(height: 16),
                  _buildSettingsList(context),
                  const SizedBox(height: 32),

                  // ── Logout Button ──
                  _buildLogoutButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  UI Widgets Builders
  // ──────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textTertiary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderSubtle.withValues(alpha: 0.5),
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          SettingTile(
            title: 'Хувийн мэдээлэл',
            icon: Icons.person_outline_rounded,
            first: true,
            onTap: () {},
          ),
          _buildDivider(),
          SettingTile(
            title: 'Уран бүтээл цацах',
            icon: Icons.album_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PublishSongScreen(
                    onTrackPublished: onTrackUploaded,
                  ),
                ),
              );
            },
          ),
          _buildDivider(),
          SettingTile(
            title: 'Дууны чанар',
            icon: Icons.graphic_eq_rounded,
            trailingText: 'Хамгийн өндөр',
            onTap: () {},
          ),
          _buildDivider(),
          SettingTile(
            title: 'Төхөөрөмжүүд',
            icon: Icons.devices_rounded,
            trailingText: '1 идэвхтэй',
            onTap: () {},
          ),
          _buildDivider(),
          SettingTile(
            title: 'Мэдэгдэл',
            icon: Icons.notifications_none_rounded,
            trailingText: 'Асаалттай',
            last: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 0.5,
      color: AppColors.divider.withValues(alpha: 0.6),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => _showLogoutConfirmation(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderSubtle,
              width: 1,
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                color: AppColors.white,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Системээс гарах',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}