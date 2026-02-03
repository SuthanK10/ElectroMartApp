class Product {
  final int? id;
  final String name;
  final String? description;
  final double price;
  final double rating;
  final String image;

  const Product({
    this.id,
    required this.name,
    this.description,
    required this.price,
    this.rating = 4.5, // Default rating if API doesn't provide it
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Handle price being String, int, or double
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Product(
      id: json['id'],
      name: json['name'] ?? 'Unknown Product',
      description: json['description'],
      price: parseDouble(json['price']),
      rating: parseDouble(json['rating'] ?? 4.5),
      image: json['image'] ?? json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'rating': rating,
      'image': image,
    };
  }
}
