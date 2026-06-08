import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';

/// Minimal bottom navigation bar.
/// Active state: white pill/capsule background with black icon.
/// Clean monochrome — no glow, no shadow, no dot.
class CustomBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav>
    with TickerProviderStateMixin {
  static const int _tabCount = 4;

  late List<AnimationController> _bounceControllers;
  late List<Animation<double>> _bounceAnimations;

  @override
  void initState() {
    super.initState();

    _bounceControllers = List.generate(_tabCount, (_) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 320),
      );
    });

    _bounceAnimations = _bounceControllers.map((controller) {
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.88), weight: 25),
        TweenSequenceItem(tween: Tween(begin: 0.88, end: 1.06), weight: 45),
        TweenSequenceItem(tween: Tween(begin: 1.06, end: 1.0), weight: 30),
      ]).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ));
    }).toList();
  }

  void _handleTap(int index) {
    _bounceControllers[index].forward(from: 0);
    widget.onTap(index);
  }

  @override
  void dispose() {
    for (final c in _bounceControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final itemWidth = totalWidth / 4;
        const double indicatorWidth = 56;
        const double indicatorHeight = 38;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.black.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.borderSubtle.withValues(alpha: 0.4),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.4),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Sliding active tab white pill background
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                left: widget.currentIndex * itemWidth + (itemWidth - indicatorWidth) / 2,
                top: 8, // Centered vertically in the 54px bar
                child: Container(
                  width: indicatorWidth,
                  height: indicatorHeight,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(19),
                  ),
                ),
              ),
              // Nav Items Row
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      index: 0,
                      icon: Icons.home_rounded,
                      isSelected: widget.currentIndex == 0,
                      bounceAnimation: _bounceAnimations[0],
                      onTap: _handleTap,
                    ),
                    _NavItem(
                      index: 1,
                      icon: Icons.search_rounded,
                      isSelected: widget.currentIndex == 1,
                      bounceAnimation: _bounceAnimations[1],
                      onTap: _handleTap,
                    ),
                    _NavItem(
                      index: 2,
                      icon: Icons.library_music_rounded,
                      isSelected: widget.currentIndex == 2,
                      bounceAnimation: _bounceAnimations[2],
                      onTap: _handleTap,
                    ),
                    _NavItem(
                      index: 3,
                      icon: Icons.person_rounded,
                      isSelected: widget.currentIndex == 3,
                      bounceAnimation: _bounceAnimations[3],
                      onTap: _handleTap,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Individual Nav Item
// ─────────────────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final bool isSelected;
  final Animation<double> bounceAnimation;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.index,
    required this.icon,
    required this.isSelected,
    required this.bounceAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: AnimatedBuilder(
        animation: bounceAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: bounceAnimation.value,
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(
              begin: isSelected ? AppColors.iconMuted : AppColors.black,
              end: isSelected ? AppColors.black : AppColors.iconMuted,
            ),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            builder: (context, color, _) {
              return Icon(
                icon,
                color: color,
                size: 22,
              );
            },
          ),
        ),
      ),
    );
  }
}