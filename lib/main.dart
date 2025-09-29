import 'package:cafe/models/coffee_shop.dart';
import 'package:cafe/pages/intro_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'theme/colors.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CoffeeShop()),
        ChangeNotifierProvider(create: (_) => AppTheme()),
      ],
      child: Consumer<AppTheme>(
        builder: (context, appTheme, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: appTheme.isDark ? ThemeMode.dark : ThemeMode.light,
          theme: _buildLightTheme(),
          // dark
          darkTheme: _buildDarkTheme(),
          home: const IntroPage(),
        ),
      ),
    );
  }
}

ThemeData _baseTheme(ColorScheme scheme) => ThemeData(
  scaffoldBackgroundColor: scheme.background,
  colorScheme: scheme,
  useMaterial3: true,
  textTheme: GoogleFonts.dmSansTextTheme(),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: scheme.surfaceVariant,
    contentTextStyle: TextStyle(color: scheme.onSurfaceVariant),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
    ),
  ),
);

ThemeData _buildDarkTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.accent,
    brightness: Brightness.dark,
    background: AppColors.bg,
    primary: AppColors.accent,
    secondary: AppColors.accent2,
  );
  return _baseTheme(scheme).copyWith(
    textTheme: GoogleFonts.dmSansTextTheme().apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    cardColor: AppColors.card,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
    ),
  );
}

ThemeData _buildLightTheme() {
  final bg = const Color(0xFFF8F5F2);
  final card = const Color(0xFFFFFFFF);
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.accent,
    brightness: Brightness.light,
    background: bg,
    primary: AppColors.accent2,
    secondary: AppColors.accent,
  );
  return _baseTheme(scheme).copyWith(
    scaffoldBackgroundColor: bg,
    cardColor: card,
    textTheme: GoogleFonts.dmSansTextTheme().apply(
      bodyColor: const Color(0xFF1E1A17),
      displayColor: const Color(0xFF1E1A17),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.dmSans(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: const Color(0xFF1E1A17),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF1E1A17)),
    ),
  );
}
