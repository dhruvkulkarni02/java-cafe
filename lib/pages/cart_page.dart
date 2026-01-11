import 'package:cafe/models/coffee.dart';
import 'package:cafe/models/coffee_shop.dart';
import 'package:cafe/theme/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // pay button tapped
  void payNow() {
    // implement payment integration here
  }

  void _showToast(String message) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => _CupertinoToast(message: message),
    );
  }

  void _showClearCartDialog(CoffeeShop shop) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Clear Cart?'),
        content: Text(
          'Remove all ${shop.userCart.length} items from your cart?',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Clear All'),
            onPressed: () {
              HapticFeedback.mediumImpact();
              shop.clearCart();
              Navigator.pop(ctx);
              _showToast('Cart cleared');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? CupertinoColors.white : const Color(0xFF1E1A17);

    return Consumer<CoffeeShop>(
      builder: (context, shop, child) => CupertinoPageScaffold(
        backgroundColor: isDark ? AppColors.bg : const Color(0xFFF8F5F2),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Header with item count and clear button
                Row(
                  children: [
                    Text(
                      'Your Cart',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    if (shop.userCart.isNotEmpty) ...[
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
                        child: Text(
                          '${shop.userCart.length} items',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      const Spacer(),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => _showClearCartDialog(shop),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.trash,
                              size: 16,
                              color: AppColors.danger,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Clear',
                              style: TextStyle(
                                color: AppColors.danger,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: shop.userCart.isEmpty
                      ? _EmptyCartState()
                      : ListView.builder(
                          itemCount: shop.userCart.length,
                          itemBuilder: (context, index) {
                            final coffee = shop.userCart[index];
                            final quantity = shop.cartMap[coffee.name] ?? 1;
                            return _CartItemTile(
                              coffee: coffee,
                              quantity: quantity,
                              onIncrement: () {
                                HapticFeedback.lightImpact();
                                shop.addItemToCart(coffee);
                              },
                              onDecrement: () {
                                HapticFeedback.lightImpact();
                                shop.removeItemFromCart(coffee);
                              },
                              onDismiss: () {
                                HapticFeedback.mediumImpact();
                                shop.removeLine(coffee);
                                _showToastWithUndo(
                                  context,
                                  '${coffee.name} removed',
                                  () {
                                    for (var i = 0; i < quantity; i++) {
                                      shop.addItemToCart(coffee);
                                    }
                                  },
                                );
                              },
                            );
                          },
                        ),
                ),
                const SizedBox(height: 10),
                _CheckoutBar(total: shop.cartTotal(), onPay: payNow),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showToastWithUndo(BuildContext context, String message, VoidCallback onUndo) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => _CupertinoToast(
        message: message,
        onUndo: onUndo,
      ),
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

class _EmptyCartState extends StatelessWidget {
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
              CupertinoIcons.bag,
              color: AppColors.subtleText,
              size: 56,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Your cart is empty',
            style: TextStyle(
              color: isDark ? CupertinoColors.white : const Color(0xFF5D4037),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Browse our menu and add your favorites',
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

class _CartItemTile extends StatelessWidget {
  final Coffee coffee;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDismiss;

  const _CartItemTile({
    required this.coffee,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final price = double.tryParse(coffee.price) ?? 0;
    final lineTotal = price * quantity;
    final textColor = isDark ? CupertinoColors.white : const Color(0xFF1E1A17);

    Widget fallbackImage() => Container(
          color: const Color(0xFF303030),
          alignment: Alignment.center,
          child: Icon(
            CupertinoIcons.circle_grid_hex_fill,
            color: CupertinoColors.white.withOpacity(.55),
            size: 28,
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
          imageErrorBuilder: (_, __, ___) => fallbackImage(),
        );
      }
      return fallbackImage();
    }

    return Dismissible(
      key: ValueKey(coffee.name),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.danger.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(
          CupertinoIcons.trash,
          color: AppColors.danger,
          size: 28,
        ),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.card : CupertinoColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (isDark)
              BoxShadow(
                color: CupertinoColors.black.withOpacity(.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              )
            else
              BoxShadow(
                color: const Color(0xFF8B4513).withOpacity(.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: -2,
              ),
          ],
          border: Border.all(
            color: isDark
                ? CupertinoColors.white.withOpacity(.05)
                : const Color(0xFF8B4513).withOpacity(.1),
          ),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 72,
                height: 72,
                child: buildImage(),
              ),
            ),
            const SizedBox(width: 14),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coffee.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${coffee.price} each',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.subtleText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${lineTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
            // Quantity controls
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? CupertinoColors.white.withOpacity(0.05)
                    : const Color(0xFF8B4513).withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _QuantityButton(
                    icon: quantity > 1 ? CupertinoIcons.minus : CupertinoIcons.trash,
                    onTap: onDecrement,
                    isDanger: quantity == 1,
                  ),
                  Container(
                    constraints: const BoxConstraints(minWidth: 36),
                    alignment: Alignment.center,
                    child: Text(
                      '$quantity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                  _QuantityButton(
                    icon: CupertinoIcons.add,
                    onTap: onIncrement,
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

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDanger;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.all(10),
      onPressed: onTap,
      child: Icon(
        icon,
        size: 18,
        color: isDanger ? AppColors.danger : AppColors.accent,
      ), minimumSize: Size(0, 0),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  final double total;
  final VoidCallback onPay;
  const _CheckoutBar({required this.total, required this.onPay});

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? CupertinoColors.white : const Color(0xFF1E1A17);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (isDark)
            BoxShadow(
              color: CupertinoColors.black.withOpacity(.4),
              blurRadius: 20,
              offset: const Offset(0, 12),
              spreadRadius: -6,
            )
          else
            BoxShadow(
              color: const Color(0xFF8B4513).withOpacity(.15),
              blurRadius: 24,
              offset: const Offset(0, 10),
              spreadRadius: -4,
            ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  color: isDark ? AppColors.subtleText : const Color(0xFFA1887F),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: .5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Taxes calculated at payment',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.subtleText : const Color(0xFFBCAAA4),
                  letterSpacing: .2,
                ),
              ),
            ],
          ),
          CupertinoButton.filled(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
            borderRadius: BorderRadius.circular(18),
            onPressed: total > 0 ? onPay : null,
            child: const Text(
              'Pay Now',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: CupertinoColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
