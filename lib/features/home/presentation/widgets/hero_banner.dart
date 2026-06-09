import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';

class HeroBanner extends StatefulWidget {
  final String title;
  final String subtitle;
  final String followersText;
  final String badgeText;
  final List<Color> gradientColors;
  final VoidCallback onPlayTap;
  final String? imagePath;

  const HeroBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.followersText,
    required this.badgeText,
    required this.gradientColors,
    required this.onPlayTap,
    this.imagePath,
  });

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner>
    with TickerProviderStateMixin {
  // Entrance animation: fade-in + slide-up
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  // Shimmer sweep animation
  late final AnimationController _shimmerController;

  // Play button pulsing glow
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // ── Entrance ──
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));
    _entranceController.forward();

    // ── Shimmer ──
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // ── Pulse ──
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: double.infinity,
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: widget.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.glow,
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
            border: Border.all(
              color: AppColors.borderSubtle,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // ── Base background image if available ──
                if (widget.imagePath != null)
                  Positioned.fill(
                    child: Image.asset(
                      widget.imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('HeroBanner Image Load Error: $error');
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Image Error: $error',
                              style: const TextStyle(color: Colors.red, fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // ── Image overlay gradient for readability ──
                if (widget.imagePath != null)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.15),
                            Colors.black.withValues(alpha: 0.65),
                          ],
                        ),
                      ),
                    ),
                  ),

                // ── Decorative circles for depth ──
                _buildDecoCircle(
                  right: -20,
                  top: -20,
                  size: 150,
                  alpha: 0.04,
                ),
                _buildDecoCircle(
                  right: 40,
                  bottom: -50,
                  size: 180,
                  alpha: 0.025,
                ),
                _buildDecoCircle(
                  left: -30,
                  bottom: -40,
                  size: 120,
                  alpha: 0.03,
                ),
                _buildDecoCircle(
                  left: 60,
                  top: -60,
                  size: 100,
                  alpha: 0.02,
                ),
                _buildDecoCircle(
                  right: 100,
                  top: 30,
                  size: 60,
                  alpha: 0.035,
                ),

                // ── Noise texture overlay ──
                Positioned.fill(
                  child: CustomPaint(
                    painter: _NoiseTexturePainter(),
                  ),
                ),

                // ── Shimmer sweep ──
                AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, _) {
                    return Positioned.fill(
                      child: ShaderMask(
                        shaderCallback: (bounds) {
                          final double sweep =
                              _shimmerController.value * 2.0 - 0.5;
                          return LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.white.withValues(alpha: 0.0),
                              AppColors.white.withValues(alpha: 0.08),
                              AppColors.white.withValues(alpha: 0.0),
                            ],
                            stops: [
                              (sweep - 0.2).clamp(0.0, 1.0),
                              sweep.clamp(0.0, 1.0),
                              (sweep + 0.2).clamp(0.0, 1.0),
                            ],
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.srcATop,
                        child: Container(
                          color: AppColors.white,
                        ),
                      ),
                    );
                  },
                ),

                // ── Inner shadow gradient for text readability ──
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 120,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.black.withValues(alpha: 0.0),
                          AppColors.black.withValues(alpha: 0.35),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Main content layout ──
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // ── Glassmorphism badge ──
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    AppColors.white.withValues(alpha: 0.18),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              widget.badgeText.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Title ──
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // ── Subtitle ──
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const Spacer(),

                      // ── Play button + metadata row ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.followersText,
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                          // Animated pulsing play button
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              final double glowRadius =
                                  10 + 8 * _pulseAnimation.value;
                              final double glowAlpha =
                                  0.2 + 0.2 * _pulseAnimation.value;
                              return GestureDetector(
                                onTap: widget.onPlayTap,
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.white
                                            .withValues(alpha: glowAlpha),
                                        blurRadius: glowRadius,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow_rounded,
                                    color: AppColors.black,
                                    size: 28,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a translucent decorative circle for visual depth.
  Widget _buildDecoCircle({
    double? left,
    double? right,
    double? top,
    double? bottom,
    required double size,
    required double alpha,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white.withValues(alpha: alpha),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
//  Noise texture painter — subtle dot pattern
// ─────────────────────────────────────────────────

class _NoiseTexturePainter extends CustomPainter {
  // Pre-seeded random for deterministic noise layout.
  final math.Random _rng = math.Random(42);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.025)
      ..style = PaintingStyle.fill;

    // Scatter small dots across the surface.
    final int count = (size.width * size.height / 140).round();
    for (int i = 0; i < count; i++) {
      final double x = _rng.nextDouble() * size.width;
      final double y = _rng.nextDouble() * size.height;
      final double r = _rng.nextDouble() * 0.8 + 0.3;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
