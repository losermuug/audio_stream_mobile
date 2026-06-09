import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';
import 'package:streaming_app/shared/widgets/gradient_album_art.dart';

class TrackTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? duration;
  final List<Color> gradientColors;
  final bool isGridStyle;
  final VoidCallback onTap;
  final IconData defaultIcon;
  final String? imagePath;

  const TrackTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.duration,
    required this.gradientColors,
    this.isGridStyle = false,
    required this.onTap,
    this.defaultIcon = Icons.music_note_rounded,
    this.imagePath,
  });

  @override
  State<TrackTile> createState() => _TrackTileState();
}

class _TrackTileState extends State<TrackTile>
    with TickerProviderStateMixin {
  // ── Card-style animations ──
  late final AnimationController _scaleController;
  late final AnimationController _playIconController;

  // ── List-tile equalizer animation ──
  late final AnimationController _equalizerController;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    // Scale spring for card press
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    // Play icon fade-in
    _playIconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    // Equalizer looping animation
    _equalizerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _playIconController.dispose();
    _equalizerController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (widget.isGridStyle) {
      return _buildCardStyle();
    }
    return _buildListTileStyle();
  }

  // ─────────────────────────────────────────────
  //  CARD STYLE (Grid)
  // ─────────────────────────────────────────────

  Widget _buildCardStyle() {
    final Color glowColor =
        widget.gradientColors.isNotEmpty
            ? widget.gradientColors.first
            : AppColors.glow;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _playIconController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _playIconController.reverse();
      },
      child: GestureDetector(
        onTapDown: (_) {
          _scaleController.forward();
          _playIconController.forward();
        },
        onTapUp: (_) {
          _scaleController.reverse();
          widget.onTap();
        },
        onTapCancel: () {
          _scaleController.reverse();
          if (!_isHovered) _playIconController.reverse();
        },
        child: AnimatedBuilder(
          animation: _scaleController,
          builder: (context, child) {
            final double scale = 1.0 - (_scaleController.value * 0.04);
            return Transform.scale(scale: scale, child: child);
          },
          child: Container(
            width: 160,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Album cover ──
                GradientAlbumArt(
                  size: 160,
                  borderRadius: 18,
                  gradientColors: widget.gradientColors,
                  icon: widget.defaultIcon,
                  iconSize: 48,
                  iconOpacity: 0.35,
                  imagePath: widget.imagePath,
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withValues(alpha: 0.25),
                      blurRadius: 18,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: glowColor.withValues(alpha: 0.10),
                      blurRadius: 40,
                      spreadRadius: 0,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Title ──
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 3),

                // ── Subtitle ──
                Text(
                  widget.subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  LIST-TILE STYLE
  // ─────────────────────────────────────────────

  Widget _buildListTileStyle() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.white.withValues(alpha: 0.06),
        highlightColor: AppColors.white.withValues(alpha: 0.04),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderSubtle.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            children: [
              // ── Cover Art with rounded corners & shadow ──
              GradientAlbumArt(
                size: 56,
                borderRadius: 14,
                gradientColors: widget.gradientColors,
                icon: widget.defaultIcon,
                iconSize: 24,
                iconOpacity: 1.0,
                imagePath: widget.imagePath,
                boxShadow: [
                  BoxShadow(
                    color: widget.gradientColors.isNotEmpty
                        ? widget.gradientColors.first.withValues(alpha: 0.20)
                        : AppColors.glow,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),

              const SizedBox(width: 16),

              // ── Title + Subtitle ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // ── Trailing section: equalizer + duration ──
              if (widget.duration != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildEqualizerBars(),
                    const SizedBox(height: 6),
                    Text(
                      widget.duration!,
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              else
                _buildEqualizerBars(),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  ANIMATED EQUALIZER BARS
  // ─────────────────────────────────────────────

  Widget _buildEqualizerBars() {
    return AnimatedBuilder(
      animation: _equalizerController,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(3, (index) {
            // Stagger each bar with a phase offset for natural look
            final double phase = (index * 0.33) % 1.0;
            final double t = (_equalizerController.value + phase) % 1.0;
            // Sine-based height for smooth organic motion
            final double normalised =
                0.35 + 0.65 * math.sin(t * math.pi);
            final double barHeight = 4.0 + (normalised * 12.0);

            return Container(
              width: 3,
              height: barHeight,
              margin: EdgeInsets.only(left: index == 0 ? 0 : 2),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(1.5),
              ),
            );
          }),
        );
      },
    );
  }
}
