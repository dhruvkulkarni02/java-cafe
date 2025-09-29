class Coffee {
  final String name;
  final String price; // keep as String to avoid broad refactor
  final String imagePath;
  final String category;
  final String description;
  final double rating;
  bool isFavorite;

  Coffee({
    required this.name,
    required this.price,
    required this.imagePath,
    required this.category,
    this.description = '',
    this.rating = 4.5,
    this.isFavorite = false,
  });

  Coffee copyWith({bool? isFavorite}) => Coffee(
    name: name,
    price: price,
    imagePath: imagePath,
    category: category,
    description: description,
    rating: rating,
    isFavorite: isFavorite ?? this.isFavorite,
  );
}
