import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';

class SettingTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? trailingText;
  final bool first;
  final bool last;
  final VoidCallback? onTap;

  const SettingTile({
    super.key,
    required this.title,
    required this.icon,
    this.trailingText,
    this.first = false,
    this.last = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.only(
      topLeft: first ? const Radius.circular(20) : Radius.zero,
      topRight: first ? const Radius.circular(20) : Radius.zero,
      bottomLeft: last ? const Radius.circular(20) : Radius.zero,
      bottomRight: last ? const Radius.circular(20) : Radius.zero,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: AppColors.white, size: 20),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (trailingText != null) ...[
                Text(
                  trailingText!,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.grey700,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
