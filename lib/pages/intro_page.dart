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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
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
                            Icons.local_cafe,
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
                  shaderCallback: (bounds) => LinearGradient(
                    colors: const [AppColors.accent, AppColors.accent2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    "JAVA CAFÉ",
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 52,
                      color: Colors.white,
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
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 20,
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (Navigator.of(context).canPop()) return;
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(
                                milliseconds: 650,
                              ),
                              pageBuilder: (_, a1, a2) => const HomePage(),
                              transitionsBuilder: (_, animation, __, child) =>
                                  FadeTransition(
                                    opacity: CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeInOut,
                                    ),
                                    child: child,
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
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Consumer<AppTheme>(
                      builder: (_, theme, __) => InkWell(
                        onTap: theme.toggle,
                        borderRadius: BorderRadius.circular(28),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            color: Theme.of(context).cardColor,
                          ),
                          child: Icon(
                            theme.isDark
                                ? Icons.wb_sunny_rounded
                                : Icons.dark_mode_rounded,
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
