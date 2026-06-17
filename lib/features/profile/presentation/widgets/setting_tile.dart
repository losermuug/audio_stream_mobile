import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';

class SettingTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final String? trailingText;
  final bool first;
  final bool last;
  final Color iconColor;
  final VoidCallback? onTap;

  const SettingTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.trailingText,
    this.first = false,
    this.last = false,
    this.iconColor = AppColors.textSecondary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.only(
      topLeft: first ? const Radius.circular(16) : Radius.zero,
      topRight: first ? const Radius.circular(16) : Radius.zero,
      bottomLeft: last ? const Radius.circular(16) : Radius.zero,
      bottomRight: last ? const Radius.circular(16) : Radius.zero,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        splashColor: AppColors.white.withValues(alpha: 0.04),
        highlightColor: AppColors.white.withValues(alpha: 0.02),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // ── Raw minimalist icon ──
              SizedBox(
                width: 24,
                height: 24,
                child: Center(
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // ── Title & Subtitle ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // ── Trailing text ──
              if (trailingText != null) ...[
                Text(
                  trailingText!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 6),
              ],

              // ── Chevron ──
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.grey500.withValues(alpha: 0.4),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
