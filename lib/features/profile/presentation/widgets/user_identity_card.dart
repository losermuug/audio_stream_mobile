import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';

class UserIdentityCard extends StatelessWidget {
  final String userName;
  final String userRole;
  final String avatarAsset;

  const UserIdentityCard({
    super.key,
    required this.userName,
    required this.userRole,
    required this.avatarAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.borderSubtle.withValues(alpha: 0.5),
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          // User Avatar Image with solid white outline
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.grey800,
              backgroundImage: AssetImage(avatarAsset),
            ),
          ),
          const SizedBox(height: 16),
          // User Name
          Text(
            userName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          // Premium badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.12),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, color: AppColors.white, size: 6),
                const SizedBox(width: 5),
                Text(
                  userRole,
                  style: const TextStyle(
                    color: AppColors.grey100,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
