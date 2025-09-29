class Coffee {
  final String name;
  final String price; // keep as String to avoid broad refactor
  final String imagePath;
  final String category;
  final String description;
  final double rating;

  Coffee({
    required this.name,
    required this.price,
    required this.imagePath,
    required this.category,
    this.description = '',
    this.rating = 4.5,
  });
}
