import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';

class ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color? color;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;

  const ControlButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 24,
    this.color,
    this.isActive = false,
    this.activeColor = AppColors.white,
    this.inactiveColor = AppColors.iconDefault,
  });

  @override
  Widget build(BuildContext context) {
    final Color buttonColor = color ?? (isActive ? activeColor : inactiveColor);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size + 10,
        height: size + 10,
        child: Center(
          child: Icon(
            icon,
            color: buttonColor,
            size: size,
          ),
        ),
      ),
    );
  }
}
