import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';

class CategoryChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip>
    with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final AnimationController _shimmerController;
  late final AnimationController _borderController;

  late final Animation<double> _scaleAnimation;
  late final Animation<double> _shimmerAnimation;
  late final Animation<double> _borderAnimation;

  @override
  void initState() {
    super.initState();

    // Scale bounce controller
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.92)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.92, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_scaleController);

    // Shimmer sweep controller — loops while selected
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Gradient border rotation controller — loops while selected
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _borderAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      _borderController,
    );

    _syncAnimations();
  }

  @override
  void didUpdateWidget(covariant CategoryChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      _syncAnimations();
    }
  }

  void _syncAnimations() {
    if (widget.isSelected) {
      _shimmerController.repeat();
      _borderController.repeat();
    } else {
      _shimmerController.stop();
      _shimmerController.reset();
      _borderController.stop();
      _borderController.reset();
    }
  }

  void _handleTap() {
    _scaleController.forward(from: 0.0);
    widget.onTap();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    _borderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _scaleAnimation,
          _shimmerAnimation,
          _borderAnimation,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: GestureDetector(
          onTap: _handleTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.white.withValues(alpha: 0.18),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: AppColors.white.withValues(alpha: 0.06),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ]
                  : [],
            ),
            child: AnimatedBuilder(
              animation: _borderAnimation,
              builder: (context, innerChild) {
                return CustomPaint(
                  painter: widget.isSelected
                      ? _GradientBorderPainter(
                          progress: _borderAnimation.value,
                          borderRadius: 22,
                          strokeWidth: 1.5,
                        )
                      : null,
                  child: innerChild,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? AppColors.white
                      : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: widget.isSelected
                        ? Colors.transparent
                        : AppColors.borderSubtle,
                    width: 1,
                  ),
                ),
                child: AnimatedBuilder(
                  animation: _shimmerAnimation,
                  builder: (context, textChild) {
                    if (!widget.isSelected) return textChild!;
  
                    return ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            AppColors.black,
                            AppColors.black.withValues(alpha: 0.7),
                            AppColors.black,
                          ],
                          stops: [
                            (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                            _shimmerAnimation.value.clamp(0.0, 1.0),
                            (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
                          ],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.srcIn,
                      child: textChild,
                    );
                  },
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    style: TextStyle(
                      color: widget.isSelected
                          ? AppColors.black
                          : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight:
                          widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                      letterSpacing: widget.isSelected ? 0.3 : 0.0,
                      height: 1.0,
                      leadingDistribution: TextLeadingDistribution.even,
                    ),
                    child: Text(widget.label),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter that draws an animated gradient border around the chip.
class _GradientBorderPainter extends CustomPainter {
  final double progress;
  final double borderRadius;
  final double strokeWidth;

  _GradientBorderPainter({
    required this.progress,
    required this.borderRadius,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(borderRadius - strokeWidth / 2),
    );

    // Rotate the gradient sweep based on animation progress
    final sweepAngle = progress * 2 * 3.14159265;

    final paint = Paint()
      ..shader = SweepGradient(
        startAngle: sweepAngle,
        endAngle: sweepAngle + 2 * 3.14159265,
        colors: [
          AppColors.white.withValues(alpha: 0.9),
          AppColors.white.withValues(alpha: 0.3),
          AppColors.white.withValues(alpha: 0.05),
          AppColors.white.withValues(alpha: 0.3),
          AppColors.white.withValues(alpha: 0.9),
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        transform: GradientRotation(sweepAngle),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_GradientBorderPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
