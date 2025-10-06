class Coffee {
  final String name;
  final String price; // keep as String to avoid broad refactor
  final String? remoteImageUrl;
  final String category;
  final String description;
  final double rating;
  bool isFavorite;

  Coffee({
    required this.name,
    required this.price,
    this.remoteImageUrl,
    required this.category,
    this.description = '',
    this.rating = 4.5,
    this.isFavorite = false,
  });

  Coffee copyWith({
    String? name,
    String? price,
    String? remoteImageUrl,
    String? category,
    String? description,
    double? rating,
    bool? isFavorite,
  }) => Coffee(
    name: name ?? this.name,
    price: price ?? this.price,
    remoteImageUrl: remoteImageUrl ?? this.remoteImageUrl,
    category: category ?? this.category,
    description: description ?? this.description,
    rating: rating ?? this.rating,
    isFavorite: isFavorite ?? this.isFavorite,
  );
}
