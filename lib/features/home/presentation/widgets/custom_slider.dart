import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';

class CustomSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double trackHeight;
  final double thumbRadius;
  final double overlayRadius;
  final Color activeTrackColor;
  final Color inactiveTrackColor;
  final Color thumbColor;

  const CustomSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.trackHeight = 4,
    this.thumbRadius = 6,
    this.overlayRadius = 12,
    this.activeTrackColor = AppColors.white,
    this.inactiveTrackColor = const Color(0x1EFFFFFF), // AppColors.white.withOpacity(0.12)
    this.thumbColor = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: trackHeight,
        activeTrackColor: activeTrackColor,
        inactiveTrackColor: inactiveTrackColor,
        thumbColor: thumbColor,
        overlayColor: thumbColor.withValues(alpha: 0.15),
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: thumbRadius),
        overlayShape: RoundSliderOverlayShape(overlayRadius: overlayRadius),
      ),
      child: Slider(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
