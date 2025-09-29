import 'package:cafe/components/coffee_tile.dart';
import 'package:cafe/models/coffee.dart';
import 'package:cafe/models/coffee_shop.dart';
import 'package:cafe/theme/colors.dart';
import 'package:cafe/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String _selectedCategory = 'All';
  String _query = '';

  List<Coffee> _filtered(List<Coffee> all) {
    return all.where((c) {
      final matchesCategory =
          _selectedCategory == 'All' || c.category == _selectedCategory;
      final matchesQuery =
          _query.isEmpty || c.name.toLowerCase().contains(_query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  // add to cart
  void addToCart(Coffee coffee) {
    Provider.of<CoffeeShop>(context, listen: false).addItemToCart(coffee);

    // let user know it has been successfully added
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Successfully added to cart"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CoffeeShop>(
      builder: (context, value, child) => SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderBar(),
                    const SizedBox(height: 18),
                    // search
                    TextField(
                      onChanged: (val) => setState(() => _query = val),
                      decoration: InputDecoration(
                        hintText: 'Search coffee...',
                        hintStyle: const TextStyle(color: AppColors.subtleText),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.subtleText,
                        ),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: AppColors.subtleText,
                                ),
                                onPressed: () => setState(() => _query = ''),
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.card,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (final cat in const [
                            'All',
                            'Espresso',
                            'Latte',
                            'Iced',
                          ])
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedCategory = cat),
                              child: _CategoryChip(
                                label: cat,
                                selected: _selectedCategory == cat,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final list = _filtered(value.coffeeShop);
                  Coffee eachCoffee = list[index];
                  return CoffeeTile(
                    coffee: eachCoffee,
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: () => addToCart(eachCoffee),
                  );
                }, childCount: _filtered(value.coffeeShop).length),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  const _CategoryChip({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? AppColors.accent : AppColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.black : AppColors.subtleText,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppTheme>(context);
    final shop = Provider.of<CoffeeShop>(context);
    final isDark = theme.isDark;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back',
                style: TextStyle(
                  color: isDark ? AppColors.subtleText : Colors.brown.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Find your coffee',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: isDark ? 'Light Mode' : 'Dark Mode',
          onPressed: () => theme.toggle(),
          icon: Icon(isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded),
          color: isDark ? AppColors.accent : Colors.brown.shade600,
        ),
        const SizedBox(width: 4),
        _BadgeIcon(
          icon: Icons.favorite,
          count: shop.favorites.length,
          color: AppColors.accent,
        ),
        const SizedBox(width: 8),
        _BadgeIcon(
          icon: Icons.shopping_bag,
          count: shop.userCart.length,
          color: AppColors.accent2,
        ),
      ],
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  const _BadgeIcon({
    required this.icon,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            onPressed: () {},
            icon: Icon(icon, size: 22),
            color: color,
            splashRadius: 24,
          ),
        ),
        if (count > 0)
          Positioned(
            right: -2,
            top: -2,
            child: AnimatedScale(
              scale: 1,
              duration: const Duration(milliseconds: 250),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
