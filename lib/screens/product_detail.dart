import 'package:flutter/material.dart';
import '../widgets/product_tile.dart' show Product; // your shared model
import 'cart.dart';
import '../app_shell.dart'; // for "View Cart" jump

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<dynamic, dynamic>?;

    final String name   = (args?['name']  ?? 'Product') as String;
    final double price  = ((args?['price']  ?? 0) as num).toDouble();
    final double rating = ((args?['rating'] ?? 0) as num).toDouble();
    final String image  =
        (args?['image'] ?? '../assets/images/placeholder.png') as String;

    // optional extras coming from ProductsScreen
    final String? desc = args?['desc'] as String?;
    final List<dynamic>? features = args?['features'] as List<dynamic>?;
    final List<dynamic>? gallery  = args?['gallery'] as List<dynamic>?;
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
                        const Text('Description',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(desc, style: const TextStyle(height: 1.4)),
                      ],
                      if (features != null && features.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text('Key Features',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        for (final f in features) _Bullet(f.toString()),
                      ],
                      const SizedBox(height: 16),
                      const Text('Specifications',
                          style: TextStyle(fontWeight: FontWeight.bold)),
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
                const Text('Description',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(desc, style: const TextStyle(height: 1.4)),
              ],

              if (features != null && features.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Key Features',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                for (final f in features) _Bullet(f.toString()),
              ],

              const SizedBox(height: 16),
              const Text('Specifications',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _SpecsTable(specs: specs),

              const SizedBox(height: 24),
              _addToCartButton(context, name, image, rating, price),
            ],
          );
        },
      ),
    );
  }

  /* ---------- pieces ---------- */

  Widget _imageBox(String image, List<dynamic>? gallery) {
    final hasGallery = gallery != null && gallery.isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.white,
          child: hasGallery
              ? PageView.builder(
                  itemCount: gallery!.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(gallery[i] as String, fit: BoxFit.contain),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(image, fit: BoxFit.contain),
                ),
        ),
      ),
    );
  }

  Widget _titlePriceRating(String name, double price, double rating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, size: 20, color: Colors.amber),
            const SizedBox(width: 6),
            Text(rating.toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const Spacer(),
            Text('\$${price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
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
          CartStore.instance.add(Product(
            name: name,
            price: price,
            rating: rating,
            image: image,
          ));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$name added to cart'),
              action: SnackBarAction(
                label: 'View Cart',
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const AppShell(startIndex: 2)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              title: Text(entries[i].key,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
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

/* ---------- sensible default specs so you don’t touch other files ---------- */

Map<String, String> _defaultSpecsFor(String name) {
  if (name.contains('iPhone')) {
    return {
      'Chip/CPU': 'A17 Pro',
      'Display': '6.9" OLED 120Hz',
      'Storage': '256GB',
      'Camera': '48MP triple',
      'Battery': 'Fast charge, MagSafe',
      'Connectivity': '5G, Wi-Fi 6E, BT 5.3',
    };
  }
  if (name.contains('MacBook Air')) {
    return {
      'CPU/GPU': 'Apple M4',
      'Display': '13.6" Liquid Retina',
      'Memory': '8GB unified',
      'Storage': '256GB SSD',
      'Battery': 'Up to 18 hrs',
      'Ports': '2× USB-C/Thunderbolt',
    };
  }
  if (name.contains('WH-1000XM5') || name.contains('Sony')) {
    return {
      'Type': 'Over-ear ANC',
      'Battery': '30 hrs',
      'Charging': 'USB-C fast',
      'Codecs': 'LDAC / AAC / SBC',
      'Weight': '≈250 g',
    };
  }
  if (name.contains('Watch')) {
    return {
      'Case': '45mm',
      'Display': 'Always-On Retina',
      'Sensors': 'HR, SpO₂',
      'Water': 'WR50',
      'Battery': 'Up to 18 hrs',
    };
  }
  if (name.contains('Samsung') || name.contains('S25')) {
    return {
      'Chip/CPU': 'Snapdragon 8 Gen 4',
      'Display': '6.8" LTPO 120Hz',
      'Camera': '200MP quad',
      'S-Pen': 'Built-in',
      'Battery': '5000 mAh',
    };
  }
  if (name.contains('iPad Pro')) {
    return {
      'Chip/CPU': 'Apple M4',
      'Display': '12.9" 120Hz',
      'Pencil': 'Apple Pencil Pro',
      'Storage': '256GB',
      'Battery': 'All-day',
    };
  }
  return {'Model': name, 'Warranty': '1 Year'};
}
