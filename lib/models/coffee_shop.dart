import 'dart:convert';
import 'package:cafe/models/coffee.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoffeeShop extends ChangeNotifier {
  CoffeeShop();

  final List<Coffee> _shop = [];
  final List<Coffee> _userCart = [];
  final Map<String, int> _cartQuantities = {}; // key: coffee name -> qty
  final List<Coffee> _favorites = [];

  bool _isLoading = false;
  bool _hasLoadedOnce = false;
  String? _errorMessage;

  List<Coffee> get coffeeShop => List.unmodifiable(_shop);
  List<String> get categories =>
      {for (final coffee in _shop) coffee.category}.toList()..sort();
  List<Coffee> get userCart => _expandedCart();
  Map<String, int> get cartMap => Map.unmodifiable(_cartQuantities);
  List<Coffee> get favorites => List.unmodifiable(_favorites);
  bool get isLoading => _isLoading && !_hasLoadedOnce;
  bool get isRefreshing => _isLoading && _hasLoadedOnce;
  String? get errorMessage => _errorMessage;
  bool get hasLoaded => _hasLoadedOnce;

  Future<void> load({bool forceRefresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    if (!hasLoaded || forceRefresh) {
      notifyListeners();
    }

    try {
      if (forceRefresh || !_hasLoadedOnce) {
        _loadMenu();
      }
      await _restorePersistedState();
      _errorMessage = null;
      _hasLoadedOnce = true;
    } catch (error, stack) {
      _errorMessage = 'Unable to load the menu. Please try again.';
      if (kDebugMode) {
        debugPrint('Coffee menu load failed: $error');
        debugPrintStack(stackTrace: stack);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load(forceRefresh: true);

  void addItemToCart(Coffee coffee) {
    _cartQuantities.update(
      coffee.name,
      (value) => value + 1,
      ifAbsent: () => 1,
    );
    if (!_userCart.any((c) => c.name == coffee.name)) {
      _userCart.add(coffee);
    }
    _persist();
    notifyListeners();
  }

  void removeItemFromCart(Coffee coffee) {
    if (!_cartQuantities.containsKey(coffee.name)) return;
    final current = _cartQuantities[coffee.name]!;
    if (current <= 1) {
      _cartQuantities.remove(coffee.name);
      _userCart.removeWhere((c) => c.name == coffee.name);
    } else {
      _cartQuantities[coffee.name] = current - 1;
    }
    _persist();
    notifyListeners();
  }

  void removeLine(Coffee coffee) {
    _cartQuantities.remove(coffee.name);
    _userCart.removeWhere((c) => c.name == coffee.name);
    _persist();
    notifyListeners();
  }

  void clearCart() {
    _cartQuantities.clear();
    _userCart.clear();
    _persist();
    notifyListeners();
  }

  void toggleFavorite(Coffee coffee) {
    final target = _findCoffeeByName(coffee.name);
    if (target == null) return;
    target.isFavorite = !target.isFavorite;
    if (target.isFavorite) {
      if (!_favorites.contains(target)) _favorites.add(target);
    } else {
      _favorites.removeWhere((c) => c.name == target.name);
    }
    _persist();
    notifyListeners();
  }

  bool isFavorite(Coffee coffee) =>
      _favorites.any((element) => element.name == coffee.name);

  double cartTotal() {
    double sum = 0;
    for (final entry in _cartQuantities.entries) {
      final coffee = _findCoffeeByName(entry.key);
      if (coffee == null) continue;
      sum += (double.tryParse(coffee.price) ?? 0) * entry.value;
    }
    return sum;
  }

  void _loadMenu() {
    final menu = _buildHardcodedMenu();
    _shop
      ..clear()
      ..addAll(menu);
  }

  List<Coffee> _buildHardcodedMenu() {
    return [
      // ─────────────────────────────────────────────
      // COFFEE DRINKS
      // ─────────────────────────────────────────────
      Coffee(
        name: 'Espresso',
        price: '3.25',
        category: 'Coffee',
        description: 'A bold, concentrated shot of rich espresso with a velvety crema.',
        rating: 4.8,
        remoteImageUrl: 'https://images.unsplash.com/photo-1510707577719-ae7c14805e3a?w=400&q=80',
      ),
      Coffee(
        name: 'Americano',
        price: '4.25',
        category: 'Coffee',
        description: 'Espresso diluted with hot water for a smooth, full-bodied coffee.',
        rating: 4.6,
        remoteImageUrl: 'https://images.unsplash.com/photo-1551030173-122aabc4489c?w=400&q=80',
      ),
      Coffee(
        name: 'Cappuccino',
        price: '5.50',
        category: 'Coffee',
        description: 'Equal parts espresso, steamed milk, and velvety foam topped with cocoa.',
        rating: 4.9,
        remoteImageUrl: 'https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=400&q=80',
      ),
      Coffee(
        name: 'Latte',
        price: '5.75',
        category: 'Coffee',
        description: 'Creamy steamed milk poured over espresso for a smooth, balanced taste.',
        rating: 4.8,
        remoteImageUrl: 'https://images.unsplash.com/photo-1561882468-9110e03e0f78?w=400&q=80',
      ),
      Coffee(
        name: 'Flat White',
        price: '5.50',
        category: 'Coffee',
        description: 'Velvety microfoam espresso drink with a stronger coffee flavor.',
        rating: 4.7,
        remoteImageUrl: 'https://images.unsplash.com/photo-1577968897966-3d4325b36b61?w=400&q=80',
      ),
      Coffee(
        name: 'Mocha',
        price: '6.25',
        category: 'Coffee',
        description: 'Rich espresso meets chocolate and steamed milk, topped with whipped cream.',
        rating: 4.9,
        remoteImageUrl: 'https://images.unsplash.com/photo-1578314675249-a6910f80cc4e?w=400&q=80',
      ),
      Coffee(
        name: 'Macchiato',
        price: '4.75',
        category: 'Coffee',
        description: 'Espresso "stained" with a dollop of foamed milk.',
        rating: 4.5,
        remoteImageUrl: 'https://images.unsplash.com/photo-1485808191679-5f86510681a2?w=400&q=80',
      ),
      Coffee(
        name: 'Cold Brew',
        price: '5.25',
        category: 'Coffee',
        description: 'Smooth, less acidic coffee steeped cold for 20 hours.',
        rating: 4.7,
        remoteImageUrl: 'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?w=400&q=80',
      ),
      Coffee(
        name: 'Iced Latte',
        price: '6.00',
        category: 'Coffee',
        description: 'Chilled espresso and milk over ice for a refreshing pick-me-up.',
        rating: 4.6,
        remoteImageUrl: 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400&q=80',
      ),
      Coffee(
        name: 'Caramel Macchiato',
        price: '6.50',
        category: 'Coffee',
        description: 'Vanilla-infused milk marked with espresso and drizzled with caramel.',
        rating: 4.8,
        remoteImageUrl: 'https://images.unsplash.com/photo-1599398054066-846a63a8f678?w=400&q=80',
      ),

      // ─────────────────────────────────────────────
      // TEA & SPECIALTY
      // ─────────────────────────────────────────────
      Coffee(
        name: 'Chai Latte',
        price: '5.50',
        category: 'Tea & Specialty',
        description: 'Spiced black tea blended with steamed milk and warming spices.',
        rating: 4.7,
        remoteImageUrl: 'https://images.unsplash.com/photo-1597318181409-cf64d0b5d8a2?w=400&q=80',
      ),
      Coffee(
        name: 'Matcha Latte',
        price: '6.25',
        category: 'Tea & Specialty',
        description: 'Ceremonial-grade matcha whisked with creamy steamed milk.',
        rating: 4.8,
        remoteImageUrl: 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=400&q=80',
      ),
      Coffee(
        name: 'London Fog',
        price: '5.75',
        category: 'Tea & Specialty',
        description: 'Earl Grey tea with vanilla and silky steamed milk.',
        rating: 4.6,
        remoteImageUrl: 'https://images.unsplash.com/photo-1571934811356-5cc061b6821f?w=400&q=80',
      ),
      Coffee(
        name: 'Hot Chocolate',
        price: '4.75',
        category: 'Tea & Specialty',
        description: 'Rich Belgian chocolate melted into steamed milk, topped with cream.',
        rating: 4.9,
        remoteImageUrl: 'https://images.unsplash.com/photo-1542990253-0d0f5be5f0ed?w=400&q=80',
      ),
      Coffee(
        name: 'Golden Milk',
        price: '5.50',
        category: 'Tea & Specialty',
        description: 'Turmeric-spiced latte with ginger, cinnamon, and oat milk.',
        rating: 4.5,
        remoteImageUrl: 'https://images.unsplash.com/photo-1615485500704-8e990f9900f7?w=400&q=80',
      ),

      // ─────────────────────────────────────────────
      // PASTRIES & FOOD
      // ─────────────────────────────────────────────
      Coffee(
        name: 'Butter Croissant',
        price: '4.25',
        category: 'Pastries & Food',
        description: 'Flaky, golden French croissant made with pure butter.',
        rating: 4.8,
        remoteImageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400&q=80',
      ),
      Coffee(
        name: 'Almond Croissant',
        price: '5.25',
        category: 'Pastries & Food',
        description: 'Buttery croissant filled with almond cream and topped with sliced almonds.',
        rating: 4.9,
        remoteImageUrl: 'https://images.unsplash.com/photo-1623334044303-241021148842?w=400&q=80',
      ),
      Coffee(
        name: 'Blueberry Muffin',
        price: '4.00',
        category: 'Pastries & Food',
        description: 'Moist muffin bursting with fresh blueberries and a crumb topping.',
        rating: 4.6,
        remoteImageUrl: 'https://images.unsplash.com/photo-1607958996333-41aef7caefaa?w=400&q=80',
      ),
      Coffee(
        name: 'Avocado Toast',
        price: '9.50',
        category: 'Pastries & Food',
        description: 'Smashed avocado on sourdough with cherry tomatoes, feta, and chili flakes.',
        rating: 4.7,
        remoteImageUrl: 'https://images.unsplash.com/photo-1541519227354-08fa5d50c44d?w=400&q=80',
      ),
      Coffee(
        name: 'Breakfast Sandwich',
        price: '8.75',
        category: 'Pastries & Food',
        description: 'Scrambled eggs, cheddar, and bacon on a toasted brioche bun.',
        rating: 4.8,
        remoteImageUrl: 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=400&q=80',
      ),
    ];
  }

  Coffee? _findCoffeeByName(String name) {
    try {
      return _shop.firstWhere((c) => c.name == name);
    } catch (_) {
      return null;
    }
  }

  Future<void> _restorePersistedState() async {
    final prefs = await SharedPreferences.getInstance();

    // Restore favorites
    final favRaw = prefs.getStringList('favorites_v1') ?? [];
    _favorites.clear();
    for (final coffee in _shop) {
      coffee.isFavorite = favRaw.contains(coffee.name);
      if (coffee.isFavorite) {
        _favorites.add(coffee);
      }
    }

    // Restore cart
    _cartQuantities.clear();
    _userCart.clear();
    final cartJson = prefs.getString('cart_v1');
    if (cartJson != null) {
      try {
        final decoded = jsonDecode(cartJson) as Map<String, dynamic>;
        decoded.forEach((name, qty) {
          if (qty is int && qty > 0) {
            final coffee = _findCoffeeByName(name);
            if (coffee != null) {
              _cartQuantities[name] = qty;
              if (!_userCart.contains(coffee)) {
                _userCart.add(coffee);
              }
            }
          }
        });
      } catch (_) {
        // ignore corrupted cache
      }
    }
  }

  List<Coffee> _expandedCart() {
    final list = <Coffee>[];
    for (final coffee in _userCart) {
      final qty = _cartQuantities[coffee.name] ?? 0;
      if (qty > 0) list.add(coffee);
    }
    return list;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'favorites_v1',
      _favorites.map((e) => e.name).toList(),
    );
    await prefs.setString('cart_v1', jsonEncode(_cartQuantities));
  }
}
