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
      SnackBar(
        content: Text('${coffee.name} added to cart'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CoffeeShop>(
      builder: (context, shop, child) {
        final coffees = _filtered(shop.coffeeShop);
        final hasError = shop.errorMessage != null && !shop.isLoading;
        final shouldShowEmpty =
            !shop.isLoading && shop.hasLoaded && coffees.isEmpty && !hasError;

        return SafeArea(
          child: RefreshIndicator(
            color: AppColors.accent,
            onRefresh: shop.refresh,
            displacement: 80,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                            hintStyle: const TextStyle(
                              color: AppColors.subtleText,
                            ),
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
                                    onPressed: () =>
                                        setState(() => _query = ''),
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
                          height: 42,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            child: ListView(
                              key: ValueKey(shop.categories.length),
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              children: [
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedCategory = 'All'),
                                  child: _CategoryChip(
                                    label: 'All',
                                    selected: _selectedCategory == 'All',
                                  ),
                                ),
                                for (final cat in shop.categories)
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
                        ),
                        if (shop.isRefreshing)
                          const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: LinearProgressIndicator(minHeight: 3),
                          ),
                        if (shop.hasLoaded && coffees.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 250),
                              opacity: 1,
                              child: Text(
                                '${coffees.length} drinks • ${shop.categories.length} categories',
                                style: TextStyle(
                                  color: AppColors.subtleText.withOpacity(0.85),
                                  fontSize: 12,
                                  letterSpacing: .3,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                if (shop.isLoading && !shop.hasLoaded)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (hasError)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _ErrorState(
                      message: shop.errorMessage!,
                      onRetry: shop.refresh,
                    ),
                  )
                else if (shouldShowEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final eachCoffee = coffees[index];
                        return CoffeeTile(
                          coffee: eachCoffee,
                          onPressed: () => addToCart(eachCoffee),
                          icon: const Icon(Icons.add, size: 18),
                          enableAddAnimation: true,
                        );
                      }, childCount: coffees.length),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  const _CategoryChip({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = selected
        ? AppColors.accent
        : (isDark ? AppColors.card : Colors.brown.withOpacity(.08));
    final txtColor = selected
        ? Colors.black
        : (isDark ? AppColors.subtleText : Colors.brown.shade500);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: txtColor,
          fontWeight: FontWeight.w600,
          fontSize: 13,
          letterSpacing: .3,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        Icon(Icons.coffee_outlined, size: 56, color: AppColors.subtleText),
        SizedBox(height: 16),
        Text(
          'No drinks match your filters',
          style: TextStyle(color: AppColors.subtleText, fontSize: 16),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.wifi_off_rounded,
          size: 56,
          color: AppColors.subtleText,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            message,
            style: const TextStyle(color: AppColors.subtleText, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () => onRetry(),
          child: const Text('Try Again'),
        ),
      ],
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
