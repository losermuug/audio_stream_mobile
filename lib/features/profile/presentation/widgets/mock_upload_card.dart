import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';

class MockUploadCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool hasFile;
  final VoidCallback onTap;

  const MockUploadCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.hasFile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasFile ? AppColors.white : AppColors.borderSubtle,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              hasFile ? Icons.check_circle_outline_rounded : icon,
              color: hasFile ? AppColors.white : AppColors.iconDefault,
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: hasFile ? AppColors.textSecondary : AppColors.textTertiary,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
