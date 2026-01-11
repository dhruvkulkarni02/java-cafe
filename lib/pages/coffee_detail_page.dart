import 'package:cafe/models/coffee.dart';
import 'package:cafe/models/coffee_shop.dart';
import 'package:cafe/theme/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:provider/provider.dart';

enum CoffeeSize { small, medium, large }

enum Temperature { hot, iced }

enum IceLevel { none, light, regular, extra }

enum SugarLevel { none, low, medium, high }

extension CoffeeSizeExtension on CoffeeSize {
  String get label {
    switch (this) {
      case CoffeeSize.small:
        return 'S';
      case CoffeeSize.medium:
        return 'M';
      case CoffeeSize.large:
        return 'L';
    }
  }

  String get fullLabel {
    switch (this) {
      case CoffeeSize.small:
        return 'Small';
      case CoffeeSize.medium:
        return 'Medium';
      case CoffeeSize.large:
        return 'Large';
    }
  }

  double get priceModifier {
    switch (this) {
      case CoffeeSize.small:
        return -0.50;
      case CoffeeSize.medium:
        return 0;
      case CoffeeSize.large:
        return 1.00;
    }
  }

  double get iconScale {
    switch (this) {
      case CoffeeSize.small:
        return 0.75;
      case CoffeeSize.medium:
        return 1.0;
      case CoffeeSize.large:
        return 1.25;
    }
  }
}

extension TemperatureExtension on Temperature {
  String get label {
    switch (this) {
      case Temperature.hot:
        return 'Hot';
      case Temperature.iced:
        return 'Iced';
    }
  }
}

extension IceLevelExtension on IceLevel {
  String get label {
    switch (this) {
      case IceLevel.none:
        return 'No Ice';
      case IceLevel.light:
        return 'Light';
      case IceLevel.regular:
        return 'Regular';
      case IceLevel.extra:
        return 'Extra';
    }
  }
}

extension SugarLevelExtension on SugarLevel {
  String get label {
    switch (this) {
      case SugarLevel.none:
        return 'No Sugar';
      case SugarLevel.low:
        return 'Low';
      case SugarLevel.medium:
        return 'Medium';
      case SugarLevel.high:
        return 'High';
    }
  }
}

class CoffeeDetailPage extends StatefulWidget {
  final Coffee coffee;
  const CoffeeDetailPage({super.key, required this.coffee});

  @override
  State<CoffeeDetailPage> createState() => _CoffeeDetailPageState();
}

class _CoffeeDetailPageState extends State<CoffeeDetailPage> {
  CoffeeSize _selectedSize = CoffeeSize.medium;
  Temperature _selectedTemp = Temperature.hot;
  IceLevel _selectedIceLevel = IceLevel.regular;
  SugarLevel _selectedSugarLevel = SugarLevel.medium;
  int _quantity = 1;

  bool get _isBeverage {
    final category = widget.coffee.category.toLowerCase();
    return category.contains('coffee') || 
           category.contains('tea') || 
           category.contains('specialty');
  }

  bool get _showIceLevel => _isBeverage && _selectedTemp == Temperature.iced;
  bool get _showTemperature => _isBeverage;
  bool get _showSugarLevel => _isBeverage;

  double get _adjustedPrice {
    final basePrice = double.tryParse(widget.coffee.price) ?? 0;
    return (basePrice + _selectedSize.priceModifier) * _quantity;
  }

  double get _unitPrice {
    final basePrice = double.tryParse(widget.coffee.price) ?? 0;
    return basePrice + _selectedSize.priceModifier;
  }

  void _showToast(String message, {VoidCallback? onUndo}) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => _CupertinoToast(
        message: message,
        onUndo: onUndo,
      ),
    );
  }

  void _addToCart() {
    HapticFeedback.mediumImpact();
    final shop = Provider.of<CoffeeShop>(context, listen: false);
    for (var i = 0; i < _quantity; i++) {
      shop.addItemToCart(widget.coffee);
    }
    
    // Build customization summary
    final customizations = <String>[];
    customizations.add(_selectedSize.fullLabel);
    if (_showTemperature) {
      customizations.add(_selectedTemp.label);
    }
    if (_showIceLevel) {
      customizations.add('${_selectedIceLevel.label} Ice');
    }
    if (_showSugarLevel && _selectedSugarLevel != SugarLevel.medium) {
      customizations.add('${_selectedSugarLevel.label} Sugar');
    }
    
    final customizationText = customizations.join(', ');
    
    _showToast(
      '$_quantity × ${widget.coffee.name} ($customizationText) added',
      onUndo: () {
        for (var i = 0; i < _quantity; i++) {
          shop.removeItemFromCart(widget.coffee);
        }
      },
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final shop = Provider.of<CoffeeShop>(context);
    final isFav = shop.isFavorite(widget.coffee);
    final scaffoldBg = isDark ? AppColors.bg : const Color(0xFFF8F5F2);
    final textColor = isDark ? CupertinoColors.white : const Color(0xFF1E1A17);

    return CupertinoPageScaffold(
      backgroundColor: scaffoldBg,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: scaffoldBg.withOpacity(0.9),
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: Icon(
            CupertinoIcons.back,
            color: textColor,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            HapticFeedback.lightImpact();
            shop.toggleFavorite(widget.coffee);
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              isFav ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
              key: ValueKey(isFav),
              color: isFav ? AppColors.accent : textColor,
            ),
          ),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        children: [
          _HeroImage(coffee: widget.coffee),
          const SizedBox(height: 26),
          Text(
            widget.coffee.category.toUpperCase(),
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 12,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.coffee.description.isEmpty
                ? 'Delicious handcrafted coffee beverage.'
                : widget.coffee.description,
            style: TextStyle(
              color: isDark ? AppColors.subtleText : const Color(0xFF8D6E63),
              height: 1.5,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 30),

          // Size selection
          if (_isBeverage) ...[
            Text(
              'Size',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: CoffeeSize.values.map((size) {
                final isSelected = _selectedSize == size;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _selectedSize = size);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: EdgeInsets.only(
                        right: size != CoffeeSize.large ? 12 : 0,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accent
                            : (isDark ? AppColors.card : CupertinoColors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accent
                              : (isDark
                                  ? CupertinoColors.white.withOpacity(0.1)
                                  : const Color(0xFF8B4513).withOpacity(0.15)),
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.accent.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        children: [
                          Transform.scale(
                            scale: size.iconScale,
                            child: Icon(
                              CupertinoIcons.circle_grid_hex_fill,
                              color: isSelected
                                  ? CupertinoColors.black
                                  : (isDark
                                      ? AppColors.subtleText
                                      : const Color(0xFFA1887F)),
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            size.label,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? CupertinoColors.black
                                  : (isDark ? CupertinoColors.white : const Color(0xFF5D4037)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            size.priceModifier >= 0
                                ? '+\$${size.priceModifier.toStringAsFixed(2)}'
                                : '-\$${(-size.priceModifier).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected
                                  ? CupertinoColors.black.withOpacity(0.7)
                                  : (isDark
                                      ? AppColors.subtleText
                                      : const Color(0xFFA1887F)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
          ],

          // Temperature selector (for beverages only)
          if (_showTemperature) ...[
            Text(
              'Temperature',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: Temperature.values.map((temp) {
                final isSelected = _selectedTemp == temp;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _selectedTemp = temp);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: EdgeInsets.only(
                        right: temp != Temperature.iced ? 12 : 0,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accent
                            : (isDark ? AppColors.card : CupertinoColors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accent
                              : (isDark
                                  ? CupertinoColors.white.withOpacity(0.1)
                                  : const Color(0xFF8B4513).withOpacity(0.15)),
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.accent.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        temp.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? CupertinoColors.black
                              : (isDark ? CupertinoColors.white : const Color(0xFF5D4037)),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
          ],

          // Ice Level selector (for iced drinks only)
          if (_showIceLevel) ...[
            Text(
              'Ice Level',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: IceLevel.values.map((ice) {
                final isSelected = _selectedIceLevel == ice;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _selectedIceLevel = ice);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: EdgeInsets.only(
                        right: ice != IceLevel.extra ? 8 : 0,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accent
                            : (isDark ? AppColors.card : CupertinoColors.white),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accent
                              : (isDark
                                  ? CupertinoColors.white.withOpacity(0.1)
                                  : const Color(0xFF8B4513).withOpacity(0.15)),
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.accent.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        ice.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? CupertinoColors.black
                              : (isDark ? CupertinoColors.white : const Color(0xFF5D4037)),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
          ],

          // Sugar Level selector
          if (_showSugarLevel) ...[
            Text(
              'Sugar Level',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: SugarLevel.values.map((sugar) {
                final isSelected = _selectedSugarLevel == sugar;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _selectedSugarLevel = sugar);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: EdgeInsets.only(
                        right: sugar != SugarLevel.high ? 8 : 0,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accent
                            : (isDark ? AppColors.card : CupertinoColors.white),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accent
                              : (isDark
                                  ? CupertinoColors.white.withOpacity(0.1)
                                  : const Color(0xFF8B4513).withOpacity(0.15)),
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.accent.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        sugar.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? CupertinoColors.black
                              : (isDark ? CupertinoColors.white : const Color(0xFF5D4037)),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
          ],

          // Quantity selector
          Row(
            children: [
              Text(
                'Quantity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.card : CupertinoColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? CupertinoColors.white.withOpacity(0.1)
                        : const Color(0xFF8B4513).withOpacity(0.15),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _QuantityButton(
                      icon: CupertinoIcons.minus,
                      onTap: _quantity > 1
                          ? () {
                              HapticFeedback.lightImpact();
                              setState(() => _quantity--);
                            }
                          : null,
                      isDark: isDark,
                    ),
                    Container(
                      constraints: const BoxConstraints(minWidth: 48),
                      alignment: Alignment.center,
                      child: Text(
                        '$_quantity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ),
                    _QuantityButton(
                      icon: CupertinoIcons.add,
                      onTap: _quantity < 10
                          ? () {
                              HapticFeedback.lightImpact();
                              setState(() => _quantity++);
                            }
                          : null,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Price and Add to Cart
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.card : CupertinoColors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                if (isDark)
                  BoxShadow(
                    color: CupertinoColors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                else
                  BoxShadow(
                    color: const Color(0xFF8B4513).withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.subtleText
                            : const Color(0xFFA1887F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${_adjustedPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                        letterSpacing: .5,
                      ),
                    ),
                    if (_quantity > 1)
                      Text(
                        '\$${_unitPrice.toStringAsFixed(2)} each',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.subtleText
                              : const Color(0xFFA1887F),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                CupertinoButton.filled(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  onPressed: _addToCart,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(CupertinoIcons.cart_badge_plus, size: 20, color: CupertinoColors.black),
                      SizedBox(width: 8),
                      Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: CupertinoColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDark;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    return CupertinoButton(
      padding: const EdgeInsets.all(12),
      onPressed: onTap,
      child: Icon(
        icon,
        size: 20,
        color: isDisabled
            ? (isDark ? CupertinoColors.white.withOpacity(0.24) : const Color(0xFFD7CCC8))
            : AppColors.accent,
      ), minimumSize: Size(0, 0),
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
                color: const Color(0xFF303030),
                alignment: Alignment.center,
                child: const Icon(
                  CupertinoIcons.circle_grid_hex_fill,
                  color: CupertinoColors.systemGrey,
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
                        colors: [CupertinoColors.black, Colors.transparent],
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
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: CupertinoColors.white,
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
                                      CupertinoIcons.star_fill,
                                      size: 18,
                                      color: CupertinoColors.black,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      coffee.rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: CupertinoColors.black,
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
