import 'package:cafe/models/coffee_shop.dart';
import 'package:cafe/pages/intro_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'theme/colors.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final CoffeeShop? coffeeShop;
  final AppTheme? appTheme;

  const MyApp({super.key, this.coffeeShop, this.appTheme});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        if (coffeeShop == null)
          ChangeNotifierProvider(create: (_) => CoffeeShop())
        else
          ChangeNotifierProvider.value(value: coffeeShop!),
        if (appTheme == null)
          ChangeNotifierProvider(create: (_) => AppTheme())
        else
          ChangeNotifierProvider.value(value: appTheme!),
      ],
      child: Builder(
        builder: (context) {
          // kick off async loads once (post frame)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final shop = Provider.of<CoffeeShop>(context, listen: false);
            final theme = Provider.of<AppTheme>(context, listen: false);
            shop.load();
            theme.load();
          });
          return Consumer<AppTheme>(
            builder: (context, appTheme, _) {
              final isDark = appTheme.isDark;
              return CupertinoApp(
                debugShowCheckedModeBanner: false,
                theme: _buildCupertinoTheme(isDark),
                home: Theme(
                  data: isDark ? _buildDarkTheme() : _buildLightTheme(),
                  child: const IntroPage(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

CupertinoThemeData _buildCupertinoTheme(bool isDark) {
  return CupertinoThemeData(
    brightness: isDark ? Brightness.dark : Brightness.light,
    primaryColor: AppColors.accent,
    scaffoldBackgroundColor: isDark ? AppColors.bg : const Color(0xFFF8F5F2),
    barBackgroundColor: isDark
        ? AppColors.card.withOpacity(0.9)
        : const Color(0xFFFFFFFF).withOpacity(0.9),
    textTheme: CupertinoTextThemeData(
      textStyle: GoogleFonts.dmSans(
        color: isDark ? CupertinoColors.white : const Color(0xFF1E1A17),
      ),
      navTitleTextStyle: GoogleFonts.dmSans(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: isDark ? CupertinoColors.white : const Color(0xFF1E1A17),
      ),
      navLargeTitleTextStyle: GoogleFonts.dmSans(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: isDark ? CupertinoColors.white : const Color(0xFF1E1A17),
      ),
    ),
  );
}

// Material theme kept for compatibility with Material widgets that may still be used
ThemeData _baseTheme(ColorScheme scheme) => ThemeData(
  scaffoldBackgroundColor: scheme.surface,
  colorScheme: scheme,
  useMaterial3: true,
  textTheme: GoogleFonts.dmSansTextTheme(),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: scheme.surfaceContainerHighest,
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
    surface: AppColors.bg,
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
    surface: bg,
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
