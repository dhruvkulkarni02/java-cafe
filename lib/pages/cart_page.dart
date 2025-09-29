import 'package:cafe/components/coffee_tile.dart';
import 'package:cafe/models/coffee.dart';
import 'package:cafe/models/coffee_shop.dart';
import 'package:cafe/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // remove item from cart
  void removeFromCart(Coffee coffee) {
    Provider.of<CoffeeShop>(context, listen: false).removeItemFromCart(coffee);
  }

  // pay button tapped
  void payNow() {
    // implement payment integration here
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CoffeeShop>(
      builder: (context, value, child) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Your Cart',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: value.userCart.isEmpty
                    ? Center(
                        child: Text(
                          'No items yet',
                          style: TextStyle(
                            color: AppColors.subtleText,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: value.userCart.length,
                        itemBuilder: (context, index) {
                          Coffee eachCoffee = value.userCart[index];
                          return CoffeeTile(
                            coffee: eachCoffee,
                            onPressed: () => removeFromCart(eachCoffee),
                            icon: const Icon(Icons.delete_outline),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 10),
              _CheckoutBar(total: value.cartTotal(), onPay: payNow),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  final double total;
  final VoidCallback onPay;
  const _CheckoutBar({required this.total, required this.onPay});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (isDark)
            BoxShadow(
              color: Colors.black.withOpacity(.4),
              blurRadius: 20,
              offset: const Offset(0, 12),
              spreadRadius: -6,
            )
          else
            BoxShadow(
              color: Colors.brown.withOpacity(.15),
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
                  color: isDark ? AppColors.subtleText : Colors.brown.shade400,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                total.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 0,
            ),
            onPressed: onPay,
            child: const Text(
              'Pay Now',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
