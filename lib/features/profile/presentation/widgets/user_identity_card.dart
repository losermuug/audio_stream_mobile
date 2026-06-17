import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';

class UserIdentityCard extends StatelessWidget {
  final String userName;
  final String userRole;
  final String? userEmail;
  final String avatarAsset;
  final int likedCount;
  final int playlistCount;
  final int listenedCount;
  final bool isLoading;

  const UserIdentityCard({
    super.key,
    required this.userName,
    required this.userRole,
    this.userEmail,
    required this.avatarAsset,
    required this.likedCount,
    required this.playlistCount,
    required this.listenedCount,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine dot color based on role
    Color roleDotColor;
    if (userRole == 'Админ') {
      roleDotColor = const Color(0xFF00E676); // Green Accent
    } else if (userRole == 'Уран бүтээлч') {
      roleDotColor = const Color(0xFF29B6F6); // Blue Accent
    } else {
      roleDotColor = const Color(0xFFB0BEC5); // Grey/Listener
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Horizontal Header: Avatar & Name/Email ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Premium Circular Avatar
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.12),
                    width: 1.5,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    avatarAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.grey800,
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppColors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // User Info details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (userEmail != null && userEmail!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        userEmail!,
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),

                    // Clean Role Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: roleDotColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: roleDotColor.withValues(alpha: 0.15),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        userRole.toUpperCase(),
                        style: TextStyle(
                          color: roleDotColor,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ── Stats Section ──
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.borderSubtle.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                _StatItem(
                  label: 'Дуртай дуу',
                  value: likedCount,
                  isLoading: isLoading,
                ),
                const _StatDivider(),
                _StatItem(
                  label: 'Жагсаалт',
                  value: playlistCount,
                  isLoading: isLoading,
                ),
                const _StatDivider(),
                _StatItem(
                  label: 'Сонссон',
                  value: listenedCount,
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int value;
  final bool isLoading;

  const _StatItem({
    required this.label,
    required this.value,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          if (isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: AppColors.white,
              ),
            )
          else
            Text(
              '$value',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
          const SizedBox(height: 6),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 9,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.5,
      height: 20,
      color: AppColors.divider.withValues(alpha: 0.3),
    );
  }
}
