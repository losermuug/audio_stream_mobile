import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';
import 'package:streaming_app/shared/services/audio_player_service.dart';

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

  // Play button pulsing glow
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // ── Entrance ──
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));
    _entranceController.forward();

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
          height: 190,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: widget.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // ── Base background image if available ──
                if (widget.imagePath != null)
                  Positioned.fill(
                    child: Image(
                      image: AudioPlayerService.getImageProvider(widget.imagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox.shrink();
                      },
                    ),
                  ),

                // ── Image overlay gradient for readability ──
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.05),
                          Colors.black.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Main content layout ──
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // ── Simple badge ──
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.badgeText.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ── Title ──
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),

                      // ── Subtitle ──
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Play button + metadata row ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.followersText,
                            style: TextStyle(
                              color: AppColors.white.withValues(alpha: 0.6),
                              fontSize: 11,
                            ),
                          ),
                          // Minimal play button
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return GestureDetector(
                                onTap: widget.onPlayTap,
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.white.withValues(
                                      alpha: 0.9 + 0.1 * _pulseAnimation.value,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow_rounded,
                                    color: AppColors.black,
                                    size: 24,
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
}


