import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cafe/pages/home_page.dart';
import 'package:cafe/theme/colors.dart';
import 'package:provider/provider.dart';
import 'package:cafe/theme/app_theme.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
    return CupertinoPageScaffold(
      backgroundColor: isDark ? AppColors.bg : const Color(0xFFF8F5F2),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.network(
                        'https://images.pexels.com/photos/374885/pexels-photo-374885.jpeg?auto=compress&cs=tinysrgb&w=800',
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: AppColors.card,
                          alignment: Alignment.center,
                          child: const Icon(
                            CupertinoIcons.circle_grid_hex_fill,
                            size: 72,
                            color: AppColors.subtleText,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Title
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.accent, AppColors.accent2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    "JAVA CAFÉ",
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 52,
                      color: CupertinoColors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Subtitle
                Text(
                  "Brewed perfection. Crafted for you.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.subtleText,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    letterSpacing: .4,
                  ),
                ),

                const SizedBox(height: 50),

                // Get Started Button
                Row(
                  children: [
                    Expanded(
                      child: CupertinoButton.filled(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        borderRadius: BorderRadius.circular(32),
                        onPressed: () {
                          if (Navigator.of(context).canPop()) return;
                          Navigator.pushReplacement(
                            context,
                            CupertinoPageRoute(
                              builder: (_) => Theme(
                                data: isDark
                                    ? ThemeData.dark()
                                    : ThemeData.light(),
                                child: const HomePage(),
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          "Get Started",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: .5,
                            color: CupertinoColors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Consumer<AppTheme>(
                      builder: (_, theme, __) => GestureDetector(
                        onTap: theme.toggle,
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            color: isDark ? AppColors.card : CupertinoColors.white,
                          ),
                          child: Icon(
                            theme.isDark
                                ? CupertinoIcons.sun_max_fill
                                : CupertinoIcons.moon_fill,
                            color: theme.isDark
                                ? AppColors.accent
                                : AppColors.accent2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
