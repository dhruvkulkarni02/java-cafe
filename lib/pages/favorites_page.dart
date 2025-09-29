import 'package:flutter/material.dart';
import 'package:cafe/theme/colors.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.favorite_border, color: AppColors.subtleText, size: 52),
            SizedBox(height: 16),
            Text(
              'No favorites yet',
              style: TextStyle(color: AppColors.subtleText, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
