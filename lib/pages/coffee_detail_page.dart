import 'package:cafe/models/coffee.dart';
import 'package:cafe/models/coffee_shop.dart';
import 'package:cafe/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:provider/provider.dart';

class CoffeeDetailPage extends StatelessWidget {
  final Coffee coffee;
  const CoffeeDetailPage({super.key, required this.coffee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _HeroImage(coffee: coffee),
          const SizedBox(height: 26),
          Text(
            coffee.category.toUpperCase(),
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 12,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            coffee.description.isEmpty
                ? 'Delicious handcrafted coffee beverage.'
                : coffee.description,
            style: const TextStyle(
              color: AppColors.subtleText,
              height: 1.5,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Text(
                '\$${coffee.price}',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                  letterSpacing: .5,
                ),
              ),
              const Spacer(),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final shop = Provider.of<CoffeeShop>(
                      context,
                      listen: false,
                    );
                    shop.addItemToCart(coffee);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${coffee.name} added to cart'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    Navigator.pop(context, true);
                  },
                  child: const Text(
                    'Add to Cart',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  final Coffee coffee;
  const _HeroImage({required this.coffee});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'coffee-image-${coffee.name}',
      child: LayoutBuilder(
        builder: (context, constraints) {
          Widget fallbackImage() => Container(
            color: Colors.grey[850],
            alignment: Alignment.center,
            child: const Icon(
              Icons.local_cafe,
              color: Colors.white54,
              size: 56,
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
                    fallbackImage(),
              );
            }
            return fallbackImage();
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(child: buildImage()),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black87, Colors.transparent],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 18,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            coffee.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: .8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 18,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      coffee.rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
