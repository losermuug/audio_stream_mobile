import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';

class SocialButton extends StatefulWidget {
  final String text;
  final String iconPath;
  final VoidCallback? onPressed;
  final IconData? iconData;

  const SocialButton({
    super.key,
    required this.text,
    this.iconPath = '',
    this.onPressed,
    this.iconData,
  });

  @override
  State<SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<SocialButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: _isPressed ? AppColors.grey800 : AppColors.grey900,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isPressed ? AppColors.grey500 : AppColors.grey700,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.iconData != null)
              Icon(
                widget.iconData,
                size: 22,
                color: AppColors.white,
              ),
            if (widget.iconData != null) const SizedBox(width: 12),
            Text(
              widget.text,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
