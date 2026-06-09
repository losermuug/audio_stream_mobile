import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';

/// A reusable section header row: bold title on the left, a pill "Бүгд"
/// button on the right.  [onSeeAllTap] is optional; if omitted the button
/// is still rendered but does nothing.
class SectionHeader extends StatelessWidget {
  final String title;
  final String seeAllLabel;
  final VoidCallback? onSeeAllTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.seeAllLabel = 'Бүгд',
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        GestureDetector(
          onTap: onSeeAllTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.borderSubtle.withValues(alpha: 0.7),
              ),
            ),
            child: Text(
              seeAllLabel,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
