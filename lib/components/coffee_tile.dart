import 'package:cafe/models/coffee.dart';
import 'package:cafe/models/coffee_shop.dart';
import 'package:cafe/theme/colors.dart';
import 'package:cafe/pages/coffee_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CoffeeTile extends StatelessWidget {
  final Coffee coffee;
  final void Function()? onPressed;
  final Widget icon;

  const CoffeeTile({
    super.key,
    required this.coffee,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shop = Provider.of<CoffeeShop>(context, listen: true);
    final fav = shop.isFavorite(coffee);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(isDark ? 1 : .95),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          if (isDark)
            BoxShadow(
              color: Colors.black.withOpacity(.35),
              blurRadius: 18,
              offset: const Offset(0, 10),
              spreadRadius: -4,
            )
          else ...[
            BoxShadow(
              color: Colors.brown.withOpacity(.08),
              blurRadius: 18,
              offset: const Offset(0, 6),
              spreadRadius: -2,
            ),
            BoxShadow(
              color: Colors.brown.withOpacity(.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ],
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(.05)
              : Colors.brown.withOpacity(.12),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () async {
          final added = await Navigator.of(context).push(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 450),
              pageBuilder: (_, a1, a2) => FadeTransition(
                opacity: CurvedAnimation(parent: a1, curve: Curves.easeInOut),
                child: CoffeeDetailPage(coffee: coffee),
              ),
            ),
          );
          if (added == true) {
            onPressed?.call();
          }
        },
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
                      Image.network(
                        coffee.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: Colors.grey[800],
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.coffee,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.55),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () => shop.toggleFavorite(coffee),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: fav
                                  ? AppColors.accent
                                  : Colors.black.withOpacity(.35),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              fav ? Icons.favorite : Icons.favorite_border,
                              size: 16,
                              color: fav
                                  ? Colors.black
                                  : Colors.white.withOpacity(.9),
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
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
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
                              Icons.star_rounded,
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
                            ? Colors.white.withOpacity(.06)
                            : Colors.brown.withOpacity(.08),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        coffee.category,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.subtleText
                              : Colors.brown.shade400,
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
                          child: IconButton(
                            icon: icon,
                            color: Colors.black,
                            onPressed: onPressed,
                            iconSize: 20,
                            splashRadius: 22,
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
