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
    final double widgetSize = size + 14;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: widgetSize,
        height: widgetSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              color: buttonColor,
              size: size,
            ),
            if (isActive)
              Positioned(
                bottom: 0,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: activeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.6),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
