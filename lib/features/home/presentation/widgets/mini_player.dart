import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';
import 'package:streaming_app/features/home/presentation/widgets/control_button.dart';
import 'package:streaming_app/shared/widgets/gradient_album_art.dart';


class MiniPlayer extends StatefulWidget {
  final String title;
  final String artist;
  final List<Color> gradientColors;
  final bool isPlaying;
  final double progress;
  final VoidCallback onPlayPauseTap;
  final VoidCallback? onLikeTap;
  final bool isLiked;
  final String? imagePath;
  final VoidCallback? onTap;

  const MiniPlayer({
    super.key,
    required this.title,
    required this.artist,
    required this.gradientColors,
    required this.isPlaying,
    required this.progress,
    required this.onPlayPauseTap,
    this.isLiked = false,
    this.onLikeTap,
    this.imagePath,
    this.onTap,
  });

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer>
    with TickerProviderStateMixin {


  // Progress bar glow pulse
  late AnimationController _glowPulseController;
  late Animation<double> _glowPulseAnimation;

  // Marquee scroll for long titles
  late ScrollController _marqueeScrollController;
  bool _needsMarquee = false;
  bool _marqueeRunning = false;

  @override
  void initState() {
    super.initState();



    // ── Progress bar glow pulse ────────────────
    _glowPulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _glowPulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowPulseController, curve: Curves.easeInOut),
    );

    // ── Marquee ────────────────────────────────
    _marqueeScrollController = ScrollController();



    WidgetsBinding.instance.addPostFrameCallback((_) => _checkMarquee());
  }

  @override
  void didUpdateWidget(covariant MiniPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.title != oldWidget.title) {
      _marqueeRunning = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkMarquee());
    }
  }

  void _checkMarquee() {
    if (!_marqueeScrollController.hasClients) return;
    final maxScroll = _marqueeScrollController.position.maxScrollExtent;
    setState(() => _needsMarquee = maxScroll > 0);
    if (_needsMarquee && !_marqueeRunning) {
      _startMarquee();
    }
  }

  Future<void> _startMarquee() async {
    _marqueeRunning = true;
    while (_marqueeRunning && mounted && _marqueeScrollController.hasClients) {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted || !_marqueeScrollController.hasClients) break;
      final maxScroll = _marqueeScrollController.position.maxScrollExtent;
      if (maxScroll <= 0) break;
      await _marqueeScrollController.animateTo(
        maxScroll,
        duration: Duration(milliseconds: (maxScroll * 30).toInt().clamp(1500, 6000)),
        curve: Curves.linear,
      );
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_marqueeScrollController.hasClients) break;
      await _marqueeScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _marqueeRunning = false;

    _glowPulseController.dispose();
    _marqueeScrollController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.miniPlayerBackground.withValues(alpha: 0.95),
            border: Border.all(
              color: AppColors.borderSubtle.withValues(alpha: 0.5),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Progress Bar ─────────────────────
              _buildProgressBar(),

              // ── Main Row ─────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    // ── Album Art Cover ────────────
                    _buildAlbumArt(),
                    const SizedBox(width: 14),

                    // ── Track Info ─────────────────
                    Expanded(child: _buildTrackInfo()),


                    // ── Skip Back ──────────────────
                    ControlButton(
                      icon: Icons.skip_previous_rounded,
                      size: 22,
                      onTap: () {},
                    ),

                    // ── Play / Pause ───────────────
                    _buildPlayPauseButton(),

                    // ── Skip Forward ───────────────
                    ControlButton(
                      icon: Icons.skip_next_rounded,
                      size: 22,
                      onTap: () {},
                    ),

                    // ── Like Button ────────────────
                    ControlButton(
                      icon: widget.isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: widget.isLiked
                          ? const Color(0xFFFF5252)
                          : null,
                      size: 20,
                      onTap: widget.onLikeTap ??
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Тоглуулах жагсаалтад нэмэгдлээ',
                                  style: TextStyle(color: AppColors.white),
                                ),
                                backgroundColor: AppColors.grey900,
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
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

  // ──────────────────────────────────────────────
  //  Album Art — 52×52, rounded, rotates when playing
  // ──────────────────────────────────────────────
  Widget _buildAlbumArt() {
    return GestureDetector(
      onTap: widget.onPlayPauseTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (widget.isPlaying)
              BoxShadow(
                color: widget.gradientColors.last.withValues(alpha: 0.45),
                blurRadius: 14,
                spreadRadius: 2,
              ),
          ],
        ),
        child: GradientAlbumArt(
          size: 52,
          gradientColors: widget.gradientColors,
          imagePath: widget.imagePath,
          iconSize: 24,
          iconOpacity: 0.85,
          borderRadius: 12,
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  Track Info — marquee title + artist
  // ──────────────────────────────────────────────
  Widget _buildTrackInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Marquee-capable title
        SizedBox(
          height: 18,
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              // Fade edges when text overflows
              return LinearGradient(
                colors: [
                  AppColors.white.withValues(alpha: _needsMarquee ? 0.0 : 1.0),
                  AppColors.white,
                  AppColors.white,
                  AppColors.white.withValues(alpha: _needsMarquee ? 0.0 : 1.0),
                ],
                stops: const [0.0, 0.04, 0.96, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: SingleChildScrollView(
              controller: _marqueeScrollController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Text(
                widget.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
                maxLines: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          widget.artist,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }


  // ──────────────────────────────────────────────
  //  Play / Pause — AnimatedSwitcher with rotation
  // ──────────────────────────────────────────────
  Widget _buildPlayPauseButton() {
    return GestureDetector(
      onTap: widget.onPlayPauseTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return RotationTransition(
                turns: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: Icon(
              widget.isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              key: ValueKey<bool>(widget.isPlaying),
              color: AppColors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }



  // ──────────────────────────────────────────────
  //  Progress Bar — gradient glow on played portion
  // ──────────────────────────────────────────────
  Widget _buildProgressBar() {
    return SizedBox(
      width: double.infinity,
      height: 3,
      child: AnimatedBuilder(
        animation: _glowPulseAnimation,
        builder: (context, _) {
          return Stack(
            children: [
              // Unplayed track
              Container(
                width: double.infinity,
                height: 3,
                color: AppColors.waveformUnplayed.withValues(alpha: 0.5),
              ),
              // Played portion with gradient + glow
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: widget.progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.gradientColors.first.withValues(alpha: 0.7),
                        AppColors.waveformPlayed,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(2),
                      bottomRight: Radius.circular(2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.glowStrong.withValues(
                          alpha: 0.25 * _glowPulseAnimation.value,
                        ),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: widget.gradientColors.first.withValues(
                          alpha: 0.2 * _glowPulseAnimation.value,
                        ),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
