import 'package:cafe/models/coffee.dart';
import 'package:flutter/material.dart';

class CoffeeShop extends ChangeNotifier {
  // coffee for sale
  final List<Coffee> _shop = [
    Coffee(
      name: 'Cappuccino',
      price: '4.10',
      imagePath:
          'https://images.pexels.com/photos/302899/pexels-photo-302899.jpeg?auto=compress&cs=tinysrgb&w=800',
      category: 'Espresso',
      description:
          'Rich espresso with steamed milk foam, velvety texture & balanced flavor.',
      rating: 4.7,
    ),
    Coffee(
      name: 'Latte',
      price: '4.20',
      imagePath:
          'https://images.pexels.com/photos/373639/pexels-photo-373639.jpeg?auto=compress&cs=tinysrgb&w=800',
      category: 'Latte',
      description:
          'Smooth espresso blended with silky steamed milk and a light microfoam.',
      rating: 4.6,
    ),
    Coffee(
      name: 'Espresso',
      price: '3.50',
      imagePath:
          'https://images.pexels.com/photos/434213/pexels-photo-434213.jpeg?auto=compress&cs=tinysrgb&w=800',
      category: 'Espresso',
      description: 'A concentrated shot of pure coffee intensity & aroma.',
      rating: 4.8,
    ),
    Coffee(
      name: 'Iced Coffee',
      price: '4.40',
      imagePath:
          'https://images.pexels.com/photos/1187439/pexels-photo-1187439.jpeg?auto=compress&cs=tinysrgb&w=800',
      category: 'Iced',
      description: 'Chilled brew over ice with a refreshing smooth finish.',
      rating: 4.5,
    ),
  ];

  // user cart
  final List<Coffee> _userCart = [];

  // favorites
  final List<Coffee> _favorites = [];

  // get coffee list
  List<Coffee> get coffeeShop => _shop;

  // get user cart
  List<Coffee> get userCart => _userCart;
  List<Coffee> get favorites => _favorites;

  // add item to cart
  void addItemToCart(Coffee coffee) {
    _userCart.add(coffee);
    notifyListeners();
  }

  // remove item from cart
  void removeItemFromCart(Coffee coffee) {
    _userCart.remove(coffee);
    notifyListeners();
  }

  void toggleFavorite(Coffee coffee) {
    final i = _shop.indexWhere((c) => c.name == coffee.name);
    if (i != -1) {
      _shop[i].isFavorite = !_shop[i].isFavorite;
    }
    if (_shop[i].isFavorite) {
      if (!_favorites.contains(_shop[i])) _favorites.add(_shop[i]);
    } else {
      _favorites.removeWhere((c) => c.name == coffee.name);
    }
    notifyListeners();
  }

  bool isFavorite(Coffee coffee) =>
      _favorites.any((element) => element.name == coffee.name);

  double cartTotal() {
    double sum = 0;
    for (final c in _userCart) {
      sum += double.tryParse(c.price) ?? 0;
    }
    return sum;
  }
}
