import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'cart.dart';
import '../app_shell.dart'; // to jump straight to Cart tab from snackbar

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF25355E),
        foregroundColor: Colors.white,
        title: const Text(
          'Products',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService().fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text('No products found.'),
                  TextButton(
                    onPressed: () {
                      // Force rebuild effectively
                      (context as Element).markNeedsBuild();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final rawList = snapshot.data!;
          final products = rawList
              .map((json) => Product.fromJson(json))
              .toList();

          return RefreshIndicator(
            onRefresh: () async {
              // Re-trigger future
              await ApiService().fetchProducts();
              (context as Element).markNeedsBuild();
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) => _ProductCard(
                product: products[i],
                // For now, we don't have detailed hardcoded specs for API products,
                // so we pass null or generate generic details.
                details: null,
              ),
            ),
          );
        },
      ),
    );
  }
}

/* ---------------- Product Card ---------------- */

class _ProductCard extends StatelessWidget {
  final Product product;
  final Map<String, dynamic>? details;
  const _ProductCard({required this.product, this.details});

  void _openDetails(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/productDetail',
      arguments: {
        'name': product.name,
        'price': product.price,
        'rating': product.rating,
        'image': product.image,
        'desc':
            product.description ??
            details?['desc'] ??
            'No description available',
        'features':
            details?['features'] ??
            ['Great performance', 'High quality', 'Best value'],
        'gallery': details?['gallery'] ?? [product.image],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _openDetails(context), // tap anywhere -> details
      child: Card(
        elevation: 1.8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image area: pure white, uniform 16:9, full image visible
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  color: Colors.white,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      ApiService().getImageUrl(product.image),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (ctx, err, stack) => const Icon(
                        Icons.broken_image_outlined,
                        size: 40,
                        color: Colors.grey,
                      ),
                      loadingBuilder: (ctx, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Name
              Text(
                product.name,
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),

              // Rating + Price
              Row(
                children: [
                  const Icon(Icons.star, size: 18, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    product.rating.toStringAsFixed(1),
                    style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Add to Cart
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    CartStore.instance.add(product);
                    ScaffoldMessenger.of(
                      context,
                    ).hideCurrentSnackBar(); // Remove previous
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} added to cart'),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25355E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Add to Cart'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
