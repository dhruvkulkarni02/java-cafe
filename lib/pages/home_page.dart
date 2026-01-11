import 'package:cafe/pages/cart_page.dart';
import 'package:cafe/pages/favorites_page.dart';
import 'package:cafe/pages/menu_page.dart';
import 'package:cafe/theme/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cafe/models/coffee_shop.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final CupertinoTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CupertinoTabController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CupertinoTabController>.value(
      value: _controller,
      child: Consumer<CoffeeShop>(
        builder: (context, shop, _) => CupertinoTabScaffold(
          controller: _controller,
          tabBar: CupertinoTabBar(
            backgroundColor: AppColors.card.withOpacity(0.95),
            activeColor: AppColors.accent,
            inactiveColor: AppColors.subtleText,
            border: const Border(
              top: BorderSide(
                color: CupertinoColors.systemGrey5,
                width: 0.0,
              ),
            ),
            items: <BottomNavigationBarItem>[
              const BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.circle_grid_hex_fill),
                label: 'Menu',
              ),
              BottomNavigationBarItem(
                icon: _NavBadge(
                  icon: CupertinoIcons.bag,
                  count: shop.userCart.length,
                ),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: _NavBadge(
                  icon: CupertinoIcons.heart,
                  count: shop.favorites.length,
                ),
                label: 'Favorites',
              ),
            ],
          ),
          tabBuilder: (context, index) {
            return CupertinoTabView(
              builder: (context) {
                Widget content;
                switch (index) {
                  case 0:
                    content = const MenuPage();
                    break;
                  case 1:
                    content = const CartPage();
                    break;
                  case 2:
                    content = const FavoritesPage();
                    break;
                  default:
                    content = const MenuPage();
                }
                
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey(index),
                    child: content,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _NavBadge extends StatelessWidget {
  final IconData icon;
  final int count;
  const _NavBadge({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count == 0) return Icon(icon, size: 28);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, size: 28),
        Positioned(
          right: -8,
          top: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(8),
            ),
            constraints: const BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            child: Text(
              count.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                height: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
