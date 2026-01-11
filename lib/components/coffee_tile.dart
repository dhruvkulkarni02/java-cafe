import 'package:cafe/models/coffee.dart';
import 'package:cafe/models/coffee_shop.dart';
import 'package:cafe/theme/colors.dart';
import 'package:cafe/pages/coffee_detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:cafe/utils/transitions.dart';

class CoffeeTile extends StatefulWidget {
  final Coffee coffee;
  final VoidCallback? onPressed;
  final Widget icon;
  final bool enableAddAnimation;
  final int cartQuantity;

  const CoffeeTile({
    super.key,
    required this.coffee,
    required this.onPressed,
    required this.icon,
    this.enableAddAnimation = false,
    this.cartQuantity = 0,
  });

  @override
  State<CoffeeTile> createState() => _CoffeeTileState();
}

class _CoffeeTileState extends State<CoffeeTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  final Animation<double> _idleAnimation = const AlwaysStoppedAnimation(1);
  bool _showCheckmark = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: 1.15), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1), weight: 40),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onActionPressed() {
    HapticFeedback.lightImpact();
    widget.onPressed?.call();
    if (widget.enableAddAnimation) {
      _triggerAddAnimation();
    }
  }

  void _triggerAddAnimation() {
    _controller.forward(from: 0);
    setState(() => _showCheckmark = true);
    Future<void>.delayed(const Duration(milliseconds: 550), () {
      if (!mounted) return;
      setState(() => _showCheckmark = false);
    });
  }

  void _onDoubleTap() {
    HapticFeedback.mediumImpact();
    final shop = Provider.of<CoffeeShop>(context, listen: false);
    shop.toggleFavorite(widget.coffee);
  }

  Animation<double> get _effectiveScale =>
      widget.enableAddAnimation ? _scaleAnimation : _idleAnimation;

  Widget get _currentIcon {
    if (widget.enableAddAnimation && _showCheckmark) {
      return const Icon(CupertinoIcons.checkmark_alt, key: ValueKey('added'), size: 18, color: CupertinoColors.black);
    }
    return KeyedSubtree(key: const ValueKey('default'), child: widget.icon);
  }

  @override
  Widget build(BuildContext context) {
    final coffee = widget.coffee;
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final shop = Provider.of<CoffeeShop>(context, listen: true);
    final fav = shop.isFavorite(coffee);
    final cartQty = widget.cartQuantity;
    final textColor = isDark ? CupertinoColors.white : const Color(0xFF1E1A17);

    Widget fallbackImage({double iconSize = 36}) => Container(
          color: const Color(0xFF303030),
          alignment: Alignment.center,
          child: Icon(
            CupertinoIcons.circle_grid_hex_fill,
            color: CupertinoColors.white.withOpacity(.55),
            size: iconSize,
          ),
        );

    Widget buildImage() {
      final url = coffee.remoteImageUrl;
      if (url != null && url.isNotEmpty) {
        return FadeInImage.memoryNetwork(
          placeholder: kTransparentImage,
          image: url,
          fit: BoxFit.cover,
          fadeInDuration: const Duration(milliseconds: 320),
          fadeInCurve: Curves.easeInOut,
          imageErrorBuilder: (context, error, stackTrace) =>
              fallbackImage(iconSize: 34),
        );
      }
      return fallbackImage(iconSize: 34);
    }

    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      onTap: () async {
        final added = await Navigator.of(context).push(
          FadeScalePageRoute(
            page: CoffeeDetailPage(coffee: coffee),
          ),
        );
        if (added == true && widget.enableAddAnimation) {
          _triggerAddAnimation();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.card : CupertinoColors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            if (isDark)
              BoxShadow(
                color: CupertinoColors.black.withOpacity(.35),
                blurRadius: 18,
                offset: const Offset(0, 10),
                spreadRadius: -4,
              )
            else ...[
              BoxShadow(
                color: const Color(0xFF8B4513).withOpacity(.08),
                blurRadius: 18,
                offset: const Offset(0, 6),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: const Color(0xFF8B4513).withOpacity(.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ],
          border: Border.all(
            color: isDark
                ? CupertinoColors.white.withOpacity(.05)
                : const Color(0xFF8B4513).withOpacity(.12),
          ),
        ),
        child: Row(
          children: [
            // image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                bottomLeft: Radius.circular(22),
              ),
              child: Hero(
                tag: 'coffee-image-${coffee.name}',
                child: SizedBox(
                  width: 92,
                  height: 108,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(child: buildImage()),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              CupertinoColors.black.withOpacity(0.55),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            shop.toggleFavorite(coffee);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: fav
                                  ? AppColors.accent
                                  : CupertinoColors.black.withOpacity(.35),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                              child: Icon(
                                fav ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                                key: ValueKey(fav),
                                size: 16,
                                color: fav
                                    ? CupertinoColors.black
                                    : CupertinoColors.white.withOpacity(.9),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Cart quantity badge
                      if (cartQty > 0)
                        Positioned(
                          bottom: 6,
                          left: 6,
                          child: AnimatedScale(
                            scale: 1,
                            duration: const Duration(milliseconds: 250),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent2,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: CupertinoColors.black.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    CupertinoIcons.bag_fill,
                                    size: 12,
                                    color: CupertinoColors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$cartQty',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: CupertinoColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            coffee.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                              letterSpacing: .3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Row(
                          children: [
                            const Icon(
                              CupertinoIcons.star_fill,
                              size: 16,
                              color: AppColors.accent,
                            ),
                            Text(
                              coffee.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? CupertinoColors.white.withOpacity(.06)
                            : const Color(0xFF8B4513).withOpacity(.08),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        coffee.category,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.subtleText
                              : const Color(0xFFA1887F),
                          letterSpacing: .4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${coffee.price}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                            letterSpacing: .4,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ScaleTransition(
                            scale: _effectiveScale,
                            child: CupertinoButton(
                              padding: const EdgeInsets.all(10),
                              onPressed: _onActionPressed,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 240),
                                transitionBuilder: (child, animation) =>
                                    ScaleTransition(
                                  scale: animation,
                                  child: child,
                                ),
                                child: _currentIcon,
                              ), minimumSize: Size(0, 0),
                            ),
                          ),
                        ),
                      ],
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
