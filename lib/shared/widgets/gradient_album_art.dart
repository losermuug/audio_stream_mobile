import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';

/// A rounded gradient square that acts as an album art placeholder.
///
/// Accepts [size], [borderRadius], [gradientColors], [icon] and an optional
/// [boxShadow] so that callers can control glow intensity independently.
class GradientAlbumArt extends StatelessWidget {
  final double size;
  final double borderRadius;
  final List<Color> gradientColors;
  final IconData icon;
  final double iconSize;
  final double iconOpacity;
  final List<BoxShadow>? boxShadow;

  const GradientAlbumArt({
    super.key,
    required this.size,
    required this.gradientColors,
    this.borderRadius = 12,
    this.icon = Icons.music_note_rounded,
    this.iconSize = 20,
    this.iconOpacity = 0.7,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final List<Color> colors =
        gradientColors.isNotEmpty ? gradientColors : [AppColors.grey800, AppColors.grey700];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: boxShadow,
      ),
      child: Center(
        child: Icon(
          icon,
          color: AppColors.white.withValues(alpha: iconOpacity),
          size: iconSize,
        ),
      ),
    );
  }
}
