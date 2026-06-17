import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';

/// A reusable section header row: bold title on the left, a plain "Бүгд"
/// text link on the right. [onSeeAllTap] is optional.
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        GestureDetector(
          onTap: onSeeAllTap,
          child: Text(
            seeAllLabel,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
