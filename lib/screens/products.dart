import 'package:flutter/material.dart';
import '../widgets/product_tile.dart' show Product;
import 'cart.dart';
import '../app_shell.dart'; // to jump straight to Cart tab from snackbar

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Your product list (prices as double literals)
    final products = const [
      Product(
        name: 'iPhone 17 Pro Max',
        price: 1500.0,
        rating: 4.8,
        image: '../assets/images/iphone17pm.png',
      ),
      Product(
        name: 'MacBook Air M4',
        price: 1300.0,
        rating: 4.8,
        image: '../assets/images/macbookair2.jpeg',
      ),
      Product(
        name: 'Sony WH-1000XM5',
        price: 400.0,
        rating: 4.7,
        image: '../assets/images/sonyhs.png',
      ),
      Product(
        name: 'Apple Watch Series 11',
        price: 400.0,
        rating: 4.6,
        image: '../assets/images/applewatch.png',
      ),
      Product(
        name: 'Samsung Galaxy S25 Ultra',
        price: 1199.0,
        rating: 4.9,
        image: '../assets/images/samsungs25u.jpg',
      ),
      Product(
        name: 'Apple iPad Pro M4',
        price: 1099.0,
        rating: 4.8,
        image: '../assets/images/ipadpro2.jpg',
      ),
    ];

    // 🔹 Extra per-product details to show on the product view
    final detailsByName = <String, Map<String, dynamic>>{
      'iPhone 17 Pro Max': {
        'desc': 'A17 Pro chip • 120Hz ProMotion • 48MP camera • 5G',
        'features': [
          '6.9" OLED, 120Hz',
          'A17 Pro-class performance',
          '48MP triple camera',
          'MagSafe fast charging',
        ],
        'gallery': [
          '../assets/images/iphone17pm.png',
          '../assets/images/iphone17pm.png',
        ],
      },
      'MacBook Air M4': {
        'desc': 'Ultra-portable with M-series power and all-day battery.',
        'features': [
          '13"/15" Liquid Retina',
          'Apple M4 silicon',
          'Up to 18 hours battery',
          'Fanless, silent design',
        ],
        'gallery': ['../assets/images/macbookair2.jpeg'],
      },
      'Sony WH-1000XM5': {
        'desc': 'Flagship ANC headphones with premium comfort.',
        'features': [
          'Industry-leading ANC',
          '30-hour battery',
          'Multipoint Bluetooth',
          'Custom EQ in app',
        ],
        'gallery': ['../assets/images/sonyhs.png'],
      },
      'Apple Watch Series 11': {
        'desc': 'Health, fitness, and safety on your wrist.',
        'features': [
          'Always-On display',
          'Advanced health sensors',
          'Water resistant',
        ],
        'gallery': ['../assets/images/applewatch.png'],
      },
      'Samsung Galaxy S25 Ultra': {
        'desc': 'S-Pen powerhouse with a pro camera system.',
        'features': ['200MP camera', 'S-Pen built in', 'LTPO 120Hz display'],
        'gallery': ['../assets/images/samsungs25u.jpg'],
      },
      'Apple iPad Pro M4': {
        'desc': 'Pro-grade tablet for creativity and productivity.',
        'features': ['M4 performance', '120Hz ProMotion', 'Apple Pencil Pro'],
        'gallery': ['../assets/images/ipadpro2.jpg'],
      },
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF25355E),
        foregroundColor: Colors.white,
        title: const Text(
          'Products',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, i) => _ProductCard(
          product: products[i],
          details: detailsByName[products[i].name],
        ),
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
        'price': product.price,    // double
        'rating': product.rating,
        'image': product.image,
        // pass optional extras
        'desc': details?['desc'],
        'features': details?['features'],
        'gallery': details?['gallery'],
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
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        product.image,
                        fit: BoxFit.contain,
                      ),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} added to cart'),
                        action: SnackBarAction(
                          label: 'View Cart',
                          onPressed: () {
                            // Close snackbar (tidy)
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            // Jump to Cart tab inside the shell
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
