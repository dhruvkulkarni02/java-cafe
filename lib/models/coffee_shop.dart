import 'dart:convert';
import 'package:cafe/models/coffee.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CoffeeShop extends ChangeNotifier {
  CoffeeShop({http.Client? client}) : _httpClient = client ?? http.Client();

  static final Uri _drinksEndpoint = Uri.parse(
    'https://raw.githubusercontent.com/igdev116/free-food-menus-api/main/db.json',
  );

  final http.Client _httpClient;

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
        await _fetchMenu();
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

  @override
  void dispose() {
    _httpClient.close();
    super.dispose();
  }

  Future<void> _fetchMenu() async {
    final response = await _httpClient.get(_drinksEndpoint);
    if (response.statusCode != 200) {
      throw Exception('Request failed with status ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body);
    final drinks = _extractDrinks(decoded);

    var coffees = _mapToCoffeeList(drinks, applyFilter: true);
    if (coffees.isEmpty) {
      if (kDebugMode) {
        debugPrint('Drink filter yielded 0 results, relaxing constraints.');
      }
      coffees = _mapToCoffeeList(drinks, applyFilter: false);
    }
    if (coffees.isEmpty) {
      throw Exception('No coffee drinks found.');
    }
    _shop
      ..clear()
      ..addAll(coffees);
  }

  List<dynamic> _extractDrinks(dynamic decoded) {
    if (decoded is List) {
      return decoded;
    }
    if (decoded is Map<String, dynamic>) {
      final drinks = decoded['drinks'];
      if (drinks is List) {
        return drinks;
      }
    }
    throw Exception('Drinks data missing from API response.');
  }

  List<Coffee> _mapToCoffeeList(
    List<dynamic> data, {
    required bool applyFilter,
  }) {
    final seen = <String>{};
    final coffees = <Coffee>[];
    for (final entry in data) {
      if (entry is! Map<String, dynamic>) continue;
      if (applyFilter && !_looksLikeSupportedDrink(entry)) continue;
      final coffee = _mapToCoffee(entry);
      final rawId = entry['id']?.toString().trim();
      final key = (rawId != null && rawId.isNotEmpty)
          ? rawId.toLowerCase()
          : coffee.name.toLowerCase();
      if (seen.add(key)) {
        coffees.add(coffee);
      }
    }
    coffees.sort((a, b) => a.name.compareTo(b.name));
    return coffees;
  }

  Coffee _mapToCoffee(Map<String, dynamic> json) {
    final rawName = json['name']?.toString().trim();
    final name = (rawName == null || rawName.isEmpty) ? 'Coffee' : rawName;
    final rawDescription = json['dsc']?.toString().trim();
    final price = _formatPrice(json['price']);
    final rating = (json['rate'] is num)
        ? (json['rate'] as num).toDouble()
        : 4.5;
    final remoteImage = json['img']?.toString();
    final category = _inferCategory(name, rawDescription ?? '');
    return Coffee(
      name: name,
      price: price,
      remoteImageUrl: remoteImage,
      category: category,
      description: _buildDescription(
        name: name,
        rawDescription: rawDescription,
        category: category,
      ),
      rating: rating,
    );
  }

  bool _looksLikeSupportedDrink(Map<String, dynamic> json) {
    final combined = '${json['name'] ?? ''} ${json['dsc'] ?? ''}'.toLowerCase();

    const includeKeywords = [
      'coffee',
      'espresso',
      'latte',
      'mocha',
      'cappuccino',
      'brew',
      'cold brew',
      'nitro',
      'macchiato',
      'tea',
      'milk tea',
      'matcha',
      'chai',
      'boba',
      'bubble',
      'frappe',
      'smoothie',
      'lemonade',
      'juice',
      'cocktail',
      'chocolate',
      'margarita',
      'hurricane',
      'sangria',
      'spritz',
      'tonic',
      'soda',
      'shandy',
      'mocktail',
      'drink',
      'mix',
      'milkshake',
      'float',
      'shake',
      'syrup',
      'julep',
      'shot',
      'bloody',
      'mary',
      'ice cream',
      'beignet',
      'croissant',
      'pastry',
      'sandwich',
      'toast',
      'scone',
      'muffin',
      'bagel',
    ];

    const excludeKeywords = [
      'gift',
      'subscription',
      'flight',
      'tickets',
      'experience',
      'class',
      'merch',
      'candle',
      'hot dog',
      'drink bottle',
      'dinner',
    ];

    if (!includeKeywords.any((keyword) => combined.contains(keyword))) {
      return false;
    }

    if (excludeKeywords.any((keyword) => combined.contains(keyword))) {
      return false;
    }

    return true;
  }

  String _formatPrice(dynamic price) {
    final parsed = switch (price) {
      num value => value.toDouble(),
      _ => double.tryParse(price?.toString() ?? ''),
    };

    final normalized = _normalizePrice(parsed ?? 0);
    return normalized.toStringAsFixed(2);
  }

  String _inferCategory(String name, String description) {
    final text = '$name $description'.toLowerCase();
    if (text.contains('matcha')) return 'Matcha';
    if (text.contains('boba') || text.contains('bubble')) return 'Boba Tea';
    if (text.contains('tea') || text.contains('chai')) return 'Tea';
    if (text.contains('iced') || text.contains('cold brew')) return 'Iced';
    if (text.contains('mocha') ||
        text.contains('chocolate') ||
        text.contains('cocoa')) {
      return 'Chocolate';
    }
    if (text.contains('latte') ||
        text.contains('macchiato') ||
        text.contains('frappe')) {
      return 'Latte';
    }
    if (text.contains('espresso') ||
        text.contains('ristretto') ||
        text.contains('doppio')) {
      return 'Espresso';
    }
    if (text.contains('smoothie')) return 'Smoothie';
    if (text.contains('mocktail') ||
        text.contains('margarita') ||
        text.contains('sangria') ||
        text.contains('spritz') ||
        text.contains('cocktail') ||
        text.contains('shandy')) {
      return 'Cocktail';
    }
    if (text.contains('syrup') || text.contains('extract')) return 'Syrup';
    if (text.contains('lemonade') || text.contains('juice')) return 'Juice';
    if (text.contains('soda') || text.contains('tonic')) return 'Soda';
    if (text.contains('coffee cake') ||
        text.contains('pastry') ||
        text.contains('croissant') ||
        text.contains('scone') ||
        text.contains('muffin') ||
        text.contains('bagel') ||
        text.contains('toast')) {
      return 'Bakery';
    }
    if (text.contains('sandwich')) return 'Savory Bite';
    return 'Specialty Drink';
  }

  double _normalizePrice(double price) {
    if (price <= 0) return 4.50;
    double normalized = price;
    if (price >= 40) {
      normalized = price / 12; // e.g. 60 -> 5.0
    } else if (price >= 20) {
      normalized = price / 3.5; // e.g. 24 -> 6.85
    }
    if (normalized < 3.75) normalized = 3.75;
    if (normalized > 12) normalized = 12.0;
    return normalized;
  }

  String _buildDescription({
    required String name,
    String? rawDescription,
    required String category,
  }) {
    final description = rawDescription?.trim();
    if (description != null && description.isNotEmpty) {
      return description;
    }

    final base = switch (category) {
      'Matcha' =>
        'Whisked ceremonial-grade matcha with velvety milk for a naturally sweet, vibrant green sip.',
      'Boba Tea' =>
        'Chewy tapioca pearls swimming in a creamy tea blend for a playful, refreshing treat.',
      'Tea' =>
        'A thoughtfully steeped tea featuring balanced aromatics and a soothing finish.',
      'Iced' =>
        'Chilled over clinking ice to highlight bright notes and a smooth, refreshing finish.',
      'Chocolate' =>
        'Silky cocoa blended with steamed milk for a decadent, dessert-worthy drink.',
      'Latte' =>
        'Expertly pulled espresso mellowed by textured milk for a balanced, velvety latte.',
      'Espresso' =>
        'Bold, aromatic espresso crafted from freshly ground beans for a rich crema.',
      'Smoothie' =>
        'A blended medley of ripe fruit and creamy textures for a revitalizing sip.',
      'Cocktail' =>
        'A barista-inspired mocktail with layered flavors and a sophisticated finish.',
      'Syrup' =>
        'Our house syrup adds a touch of sweetness and depth to your favorite drinks.',
      'Juice' =>
        'Pressed and poured to capture vibrant fruit character with a clean finish.',
      _ =>
        'A signature ${category.toLowerCase()} crafted with premium ingredients and barista-level care.',
    };

    return '$name — $base';
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
