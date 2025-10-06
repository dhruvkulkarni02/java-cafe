import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme extends ChangeNotifier {
  bool _isDark = true;
  bool get isDark => _isDark;

  void toggle() {
    _isDark = !_isDark;
    _persist();
    notifyListeners();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('theme_dark_v1') ?? true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('theme_dark_v1', _isDark);
  }
}
