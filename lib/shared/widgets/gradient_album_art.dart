import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';
import 'package:streaming_app/shared/services/audio_player_service.dart';

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
  final String? imagePath;

  const GradientAlbumArt({
    super.key,
    required this.size,
    required this.gradientColors,
    this.borderRadius = 12,
    this.icon = Icons.music_note_rounded,
    this.iconSize = 20,
    this.iconOpacity = 0.7,
    this.boxShadow,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final List<Color> colors =
        gradientColors.isNotEmpty ? gradientColors : [AppColors.grey800, AppColors.grey700];

    final hasImage = imagePath != null && imagePath!.isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow,
        gradient: hasImage
            ? null
            : LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
      ),
      child: hasImage
          ? ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Image(
                image: AudioPlayerService.getImageProvider(imagePath),
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        color: AppColors.white.withValues(alpha: iconOpacity),
                        size: iconSize,
                      ),
                    ),
                  );
                },
              ),
            )
          : Center(
              child: Icon(
                icon,
                color: AppColors.white.withValues(alpha: iconOpacity),
                size: iconSize,
              ),
            ),
    );
  }
}
