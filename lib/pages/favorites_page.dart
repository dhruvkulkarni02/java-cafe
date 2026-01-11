import 'package:cafe/components/coffee_tile.dart';
import 'package:cafe/models/coffee_shop.dart';
import 'package:cafe/theme/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerController;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  void _triggerAnimation() {
    if (!_hasAnimated) {
      _hasAnimated = true;
      _staggerController.forward();
    }
  }

  void _showToast(BuildContext context, String message, {VoidCallback? onUndo}) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => _CupertinoToast(
        message: message,
        onUndo: onUndo,
      ),
    );
  }

  void _addToCart(CoffeeShop shop, coffee) {
    HapticFeedback.lightImpact();
    shop.addItemToCart(coffee);
    _showToast(
      context,
      '${coffee.name} added to cart',
      onUndo: () {
        HapticFeedback.lightImpact();
        shop.removeItemFromCart(coffee);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? CupertinoColors.white : const Color(0xFF1E1A17);

    return Consumer<CoffeeShop>(
      builder: (context, shop, _) {
        if (shop.favorites.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _triggerAnimation();
          });
        }

        return CupertinoPageScaffold(
          backgroundColor: isDark ? AppColors.bg : const Color(0xFFF8F5F2),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Favorites',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      if (shop.favorites.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                CupertinoIcons.heart_fill,
                                size: 14,
                                color: AppColors.accent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${shop.favorites.length}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: shop.favorites.isEmpty
                        ? _EmptyFavoritesState()
                        : ListView.builder(
                            itemCount: shop.favorites.length,
                            itemBuilder: (context, index) {
                              final coffee = shop.favorites[index];
                              final cartQty = shop.cartMap[coffee.name] ?? 0;

                              return AnimatedBuilder(
                                animation: _staggerController,
                                builder: (context, child) {
                                  final delay = (index * 0.15).clamp(0.0, 0.5);
                                  final animValue = Curves.easeOut.transform(
                                    ((_staggerController.value - delay) /
                                            (1 - delay))
                                        .clamp(0.0, 1.0),
                                  );

                                  return Transform.translate(
                                    offset: Offset(0, 30 * (1 - animValue)),
                                    child: Opacity(
                                      opacity: animValue,
                                      child: child,
                                    ),
                                  );
                                },
                                child: CoffeeTile(
                                  coffee: coffee,
                                  onPressed: () => _addToCart(shop, coffee),
                                  icon: const Icon(CupertinoIcons.add, size: 18),
                                  enableAddAnimation: true,
                                  cartQuantity: cartQty,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CupertinoToast extends StatefulWidget {
  final String message;
  final VoidCallback? onUndo;

  const _CupertinoToast({required this.message, this.onUndo});

  @override
  State<_CupertinoToast> createState() => _CupertinoToastState();
}

class _CupertinoToastState extends State<_CupertinoToast> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 100, left: 24, right: 24),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                widget.message,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (widget.onUndo != null) ...[
              const SizedBox(width: 16),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  widget.onUndo!();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Undo',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ), minimumSize: Size(0, 0),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyFavoritesState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: (isDark ? CupertinoColors.white : const Color(0xFF8B4513)).withOpacity(0.05),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              CupertinoIcons.heart,
              color: AppColors.subtleText,
              size: 56,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No favorites yet',
            style: TextStyle(
              color: isDark ? CupertinoColors.white : const Color(0xFF5D4037),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Double-tap any drink to add to favorites',
            style: TextStyle(
              color: AppColors.subtleText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
