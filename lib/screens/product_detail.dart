import 'package:flutter/material.dart';
import '../widgets/product_tile.dart' show Product; // shared Product model
import 'cart.dart';
import '../app_shell.dart'; // to open Cart tab from snackbar

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<dynamic, dynamic>?;

    final String name = (args?['name'] ?? 'Product') as String;
    final num priceRaw = (args?['price'] ?? 0) as num;
    final double price = priceRaw.toDouble(); // ✅ ensure double
    final double rating = ((args?['rating'] ?? 0) as num).toDouble();
    final String image =
        (args?['image'] ?? '../assets/images/placeholder.png') as String;

    // optional extras
    final String? desc = args?['desc'] as String?;
    final List<dynamic>? features = args?['features'] as List<dynamic>?;
    final List<dynamic>? gallery = args?['gallery'] as List<dynamic>?;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF25355E),
        foregroundColor: Colors.white,
        title: const Text(
          'Product Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // gallery (if provided) else single image
          if (gallery != null && gallery.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Colors.white,
                  child: PageView.builder(
                    itemCount: gallery.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(
                        gallery[i] as String,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(image, fit: BoxFit.contain),
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Title
          Text(
            name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),

          // Rating + Price
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
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ],
          ),

          // Description (optional)
          if (desc != null && desc.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Description',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(desc, style: const TextStyle(height: 1.4)),
          ],

          // Features (optional)
          if (features != null && features.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Key Features',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            for (final f in features) _Bullet(f.toString()),
          ],

          const SizedBox(height: 24),

          // Add to Cart
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                CartStore.instance.add(
                  Product(
                    name: name,
                    price: price,     // ✅ double
                    rating: rating,
                    image: image,
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$name added to cart'),
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
          ),
        ],
      ),
    );
  }
}

/* small helper */
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
