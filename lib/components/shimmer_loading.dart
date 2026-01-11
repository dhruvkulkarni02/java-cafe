import 'package:cafe/theme/colors.dart';
import 'package:flutter/material.dart';

/// A shimmer effect widget for loading states
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.isLoading = true,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: const [
              Color(0x20FFFFFF),
              Color(0x40FFFFFF),
              Color(0x20FFFFFF),
            ],
            stops: [
              0.0,
              ((_animation.value + 2) / 4).clamp(0.0, 1.0),
              1.0,
            ],
            transform: GradientRotation(_animation.value * 0.5),
          ).createShader(bounds),
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}

/// Skeleton placeholder for a coffee tile during loading
class CoffeeTileSkeleton extends StatelessWidget {
  const CoffeeTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.brown.withOpacity(0.08);
    final highlightColor = isDark
        ? Colors.white.withOpacity(0.1)
        : Colors.brown.withOpacity(0.15);

    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(.05)
                : Colors.brown.withOpacity(.1),
          ),
        ),
        child: Row(
          children: [
            // Image skeleton
            Container(
              width: 92,
              height: 108,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            const SizedBox(width: 16),
            // Content skeleton
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title skeleton
                  Container(
                    height: 18,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Category skeleton
                  Container(
                    height: 24,
                    width: 80,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Price and button skeleton
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 20,
                        width: 50,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A list of shimmer skeletons for loading state
class ShimmerCoffeeList extends StatelessWidget {
  final int itemCount;

  const ShimmerCoffeeList({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => const CoffeeTileSkeleton(),
        childCount: itemCount,
      ),
    );
  }
}
