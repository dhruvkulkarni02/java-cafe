import 'package:cafe/components/coffee_tile.dart';
import 'package:cafe/models/coffee_shop.dart';
import 'package:cafe/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CoffeeShop>(
      builder: (context, shop, _) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Favorites',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: shop.favorites.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.favorite_border,
                              color: AppColors.subtleText,
                              size: 52,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No favorites yet',
                              style: TextStyle(
                                color: AppColors.subtleText,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: shop.favorites.length,
                        itemBuilder: (context, index) {
                          final coffee = shop.favorites[index];
                          return CoffeeTile(
                            coffee: coffee,
                            onPressed: () => Provider.of<CoffeeShop>(
                              context,
                              listen: false,
                            ).toggleFavorite(coffee),
                            icon: const Icon(Icons.favorite, size: 18),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
