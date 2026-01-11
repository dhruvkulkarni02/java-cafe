import 'package:cafe/components/coffee_tile.dart';
import 'package:cafe/components/shimmer_loading.dart';
import 'package:cafe/models/coffee.dart';
import 'package:cafe/models/coffee_shop.dart';
import 'package:cafe/theme/colors.dart';
import 'package:cafe/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with TickerProviderStateMixin {
  String _selectedCategory = 'All';
  String _query = '';
  late final AnimationController _staggerController;
  bool _hasAnimated = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Coffee> _filtered(List<Coffee> all) {
    return all.where((c) {
      final matchesCategory =
          _selectedCategory == 'All' || c.category == _selectedCategory;
      final matchesQuery =
          _query.isEmpty || c.name.toLowerCase().contains(_query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
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

  // add to cart with undo toast
  void addToCart(Coffee coffee) {
    final shop = Provider.of<CoffeeShop>(context, listen: false);
    shop.addItemToCart(coffee);
    HapticFeedback.lightImpact();

    _showToast(
      context,
      '${coffee.name} added to cart',
      onUndo: () {
        HapticFeedback.lightImpact();
        shop.removeItemFromCart(coffee);
      },
    );
  }

  void _triggerStaggerAnimation() {
    if (!_hasAnimated) {
      _hasAnimated = true;
      _staggerController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
    return Consumer<CoffeeShop>(
      builder: (context, shop, child) {
        final coffees = _filtered(shop.coffeeShop);
        final hasError = shop.errorMessage != null && !shop.isLoading;
        final shouldShowEmpty =
            !shop.isLoading && shop.hasLoaded && coffees.isEmpty && !hasError;

        // Trigger stagger animation when content loads
        if (shop.hasLoaded && coffees.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _triggerStaggerAnimation();
          });
        }

        return CupertinoPageScaffold(
          backgroundColor: isDark ? AppColors.bg : const Color(0xFFF8F5F2),
          child: SafeArea(
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: shop.refresh,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HeaderBar(),
                        const SizedBox(height: 18),
                        // iOS-style search field
                        CupertinoSearchTextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() => _query = val),
                          placeholder: 'Search coffee...',
                          style: TextStyle(
                            color: isDark ? CupertinoColors.white : CupertinoColors.black,
                          ),
                          backgroundColor: isDark 
                              ? AppColors.card 
                              : CupertinoColors.white,
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
                            child: CupertinoActivityIndicator(),
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
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: const ShimmerCoffeeList(itemCount: 4),
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
                        final cartQty = shop.cartMap[eachCoffee.name] ?? 0;

                        return AnimatedBuilder(
                          animation: _staggerController,
                          builder: (context, child) {
                            final delay = (index * 0.1).clamp(0.0, 0.5);
                            final animValue = Curves.easeOut.transform(
                              ((_staggerController.value - delay) / (1 - delay))
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
                            coffee: eachCoffee,
                            onPressed: () => addToCart(eachCoffee),
                            icon: const Icon(CupertinoIcons.add, size: 22, color: CupertinoColors.black),
                            enableAddAnimation: true,
                            cartQuantity: cartQty,
                          ),
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

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  const _CategoryChip({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final bg = selected
        ? AppColors.accent
        : (isDark ? AppColors.card : CupertinoColors.white);
    final txtColor = selected
        ? CupertinoColors.black
        : (isDark ? AppColors.subtleText : const Color(0xFF8B6914));
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
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: (isDark ? CupertinoColors.white : const Color(0xFF8B4513)).withOpacity(0.05),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            CupertinoIcons.circle_grid_hex_fill,
            size: 56,
            color: AppColors.subtleText,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'No drinks match your filters',
          style: TextStyle(
            color: isDark ? CupertinoColors.white : const Color(0xFF5D4037),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Try a different category or search term',
          style: TextStyle(color: AppColors.subtleText, fontSize: 14),
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
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.danger.withOpacity(0.1),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            CupertinoIcons.wifi_slash,
            size: 56,
            color: AppColors.subtleText,
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            message,
            style: TextStyle(
              color: isDark ? CupertinoColors.white : const Color(0xFF5D4037),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        CupertinoButton.filled(
          onPressed: () => onRetry(),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.refresh, size: 18),
              SizedBox(width: 8),
              Text('Try Again'),
            ],
          ),
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
    final textColor = isDark ? CupertinoColors.white : const Color(0xFF1E1A17);
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
                  color: isDark ? AppColors.subtleText : const Color(0xFFA1887F),
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
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            HapticFeedback.lightImpact();
            theme.toggle();
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.card : CupertinoColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDark ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_fill,
              color: isDark ? AppColors.accent : const Color(0xFF6D4C41),
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _BadgeIcon(
          icon: CupertinoIcons.heart_fill,
          count: shop.favorites.length,
          color: AppColors.accent,
          onTap: () {
            HapticFeedback.lightImpact();
            // Navigate to Favorites tab (index 2)
            final controller = Provider.of<CupertinoTabController>(context, listen: false);
            controller.index = 2;
          },
        ),
        const SizedBox(width: 8),
        _BadgeIcon(
          icon: CupertinoIcons.bag_fill,
          count: shop.userCart.length,
          color: AppColors.accent2,
          onTap: () {
            HapticFeedback.lightImpact();
            // Navigate to Cart tab (index 1)
            final controller = Provider.of<CupertinoTabController>(context, listen: false);
            controller.index = 1;
          },
        ),
      ],
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  final VoidCallback? onTap;
  const _BadgeIcon({
    required this.icon,
    required this.count,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.card : CupertinoColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          if (count > 0)
            Positioned(
              right: -4,
              top: -4,
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
                      color: CupertinoColors.black,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

