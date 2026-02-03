import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/product.dart'; // your shared model
import '../services/api_service.dart';
import 'cart.dart';
import '../app_shell.dart'; // for "View Cart" jump

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<dynamic, dynamic>?;

    final String name = (args?['name'] ?? 'Product') as String;
    final double price = ((args?['price'] ?? 0) as num).toDouble();
    final double rating = ((args?['rating'] ?? 0) as num).toDouble();
    final String image =
        (args?['image'] ?? '../assets/images/placeholder.png') as String;

    // optional extras coming from ProductsScreen
    final String? desc = args?['desc'] as String?;
    final List<dynamic>? features = args?['features'] as List<dynamic>?;
    final List<dynamic>? gallery = args?['gallery'] as List<dynamic>?;
    final Map<String, String> specs =
        (args?['specs'] as Map<String, String>?) ?? _defaultSpecsFor(name);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF25355E),
        foregroundColor: Colors.white,
        title: const Text(
          'Product Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // ignore: deprecated_member_use
              Share.share(
                'Check out $name on ElectroMart! Price: \$$price',
                subject: 'Look at this product!',
              );
            },
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.landscape) {
            // ⏩ Landscape: image left, details right
            return Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _imageBox(image, gallery),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _titlePriceRating(name, price, rating),
                      if (desc != null && desc.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Description',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(desc, style: const TextStyle(height: 1.4)),
                      ],
                      if (features != null && features.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Key Features',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        for (final f in features) _Bullet(f.toString()),
                      ],
                      const SizedBox(height: 16),
                      const Text(
                        'Specifications',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _SpecsTable(specs: specs),
                      const SizedBox(height: 20),
                      _addToCartButton(context, name, image, rating, price),
                    ],
                  ),
                ),
              ],
            );
          }

          // 📱 Portrait: same layout you already had
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _imageBox(image, gallery),
              const SizedBox(height: 16),
              _titlePriceRating(name, price, rating),

              if (desc != null && desc.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(desc, style: const TextStyle(height: 1.4)),
              ],

              if (features != null && features.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Key Features',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                for (final f in features) _Bullet(f.toString()),
              ],

              const SizedBox(height: 16),
              const Text(
                'Specifications',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _SpecsTable(specs: specs),

              const SizedBox(height: 24),
              _addToCartButton(context, name, image, rating, price),
              const SizedBox(height: 80), // 🔹 Space for SnackBar
            ],
          );
        },
      ),
    );
  }

  /* ---------- pieces ---------- */

  Widget _imageBox(String image, List<dynamic>? gallery) {
    final hasGallery = gallery != null && gallery.isNotEmpty;
    // Ensure we don't try to load the same image as a gallery if it's just a duplicate
    // (optional polish, but keeps it simple for now)

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.white,
          child: hasGallery
              ? PageView.builder(
                  itemCount: gallery.length,
                  itemBuilder: (_, i) => Image.network(
                    ApiService().getImageUrl(gallery[i] as String),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (ctx, err, stack) => const Icon(
                      Icons.broken_image_rounded,
                      size: 48,
                      color: Colors.grey,
                    ),
                  ),
                )
              : Image.network(
                  ApiService().getImageUrl(image),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (ctx, err, stack) => const Icon(
                    Icons.broken_image_rounded,
                    size: 48,
                    color: Colors.grey,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _titlePriceRating(String name, double price, double rating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, size: 20, color: Colors.amber),
            const SizedBox(width: 6),
            Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              '\$${price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ],
    );
  }

  Widget _addToCartButton(
    BuildContext context,
    String name,
    String image,
    double rating,
    double price,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          CartStore.instance.add(
            Product(name: name, price: price, rating: rating, image: image),
          );
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$name added to cart'),
              duration: const Duration(milliseconds: 1500),
              action: SnackBarAction(
                label: 'View Cart',
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const AppShell(startIndex: 2),
                    ),
                  );
                },
              ),
            ),
          );
        },
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Add to Cart'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF25355E),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/* ---------- tiny widgets ---------- */

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text, style: const TextStyle(height: 1.3))),
        ],
      ),
    );
  }
}

class _SpecsTable extends StatelessWidget {
  final Map<String, String> specs;
  const _SpecsTable({required this.specs});

  @override
  Widget build(BuildContext context) {
    final entries = specs.entries.toList();
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          for (int i = 0; i < entries.length; i++) ...[
            ListTile(
              dense: true,
              title: Text(
                entries[i].key,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: Text(entries[i].value),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            if (i != entries.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

Map<String, String> _defaultSpecsFor(String name) {
  // 🔹 GENERIC SPECS (Better practice than hardcoding per product name)
  return {
    'Product Name': name,
    'Condition': 'Brand New',
    'Warranty': '1 Year Official',
    'Availability': 'In Stock',
    'Shipping': 'Free (2-3 Business Days)',
  };
}
