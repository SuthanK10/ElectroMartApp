import 'package:flutter/material.dart';

class Product {
  final String name;
  final double price;
  final double rating;
  final String image;

  const Product({
    required this.name,
    required this.price,
    required this.rating,
    required this.image,
  });
}

class ProductTile extends StatelessWidget {
  final Product product;
  const ProductTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              product.image,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('${product.rating}'),
                  ],
                ),
                const SizedBox(height: 4),
                Text('\$${product.price}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/productDetail'),
                        child: const Text('Add to Cart'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/productDetail'),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
