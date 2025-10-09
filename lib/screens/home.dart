import 'package:flutter/material.dart';
import '../theme_controller.dart';
import '../app_shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const double _radius = 20;

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeController.instance.themeMode.value == ThemeMode.dark;

    // Featured items (same as you had)
    const featured = [
      _Product(
        image: '../assets/images/iphone17pm.png',
        name: 'iPhone 17 Pro Max',
        price: 1499.99,
        oldPrice: 1599.99,
        rating: 4.8,
        reviews: 1234,
      ),
      _Product(
        image: '../assets/images/macbookair2.jpeg',
        name: 'MacBook Air',
        price: 1299.99,
        oldPrice: 1399.99,
        rating: 4.8,
        reviews: 1234,
      ),
      _Product(
        image: '../assets/images/sonyhs.png',
        name: 'Sony WH-1000XM5',
        price: 399.99,
        oldPrice: 449.99,
        rating: 4.7,
        reviews: 860,
      ),
    ];

    // 🔹 NEW: extra details to show on the product details page
    final detailsByName = <String, Map<String, dynamic>>{
      'iPhone 17 Pro Max': {
        'desc': 'A17 Pro power with ProMotion display and advanced cameras.',
        'features': [
          '6.9" 120Hz OLED',
          'A17 Pro-class chipset',
          '48MP Pro camera system',
          'MagSafe fast charging',
        ],
        'gallery': ['../assets/images/iphone17pm.png'],
      },
      'MacBook Air': {
        'desc': 'Ultra-portable laptop with all-day battery and silent design.',
        'features': [
          'Liquid Retina display',
          'Apple Silicon performance',
          'Up to 18 hours battery',
          'Fanless, lightweight',
        ],
        'gallery': ['../assets/images/macbookair2.jpeg'],
      },
      'Sony WH-1000XM5': {
        'desc': 'Flagship noise-cancelling headphones with premium comfort.',
        'features': [
          'Industry-leading ANC',
          '30-hour battery life',
          'Multipoint Bluetooth',
          'Custom EQ in app',
        ],
        'gallery': ['../assets/images/sonyhs.png'],
      },
    };

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF25355E), // same color in both modes per your request
        elevation: 0,
        title: const Text('ElectroMart'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: const [
          Icon(Icons.search, color: Colors.white),
          SizedBox(width: 12),
          Icon(Icons.shopping_cart_outlined, color: Colors.white),
          SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          // 🔹 Hero section
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(_radius),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.grey.shade800 : const Color(0x11000000),
                    ),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Image.asset(
                        '../assets/images/hero.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Latest Electronics at\nUnbeatable Prices',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Discover cutting-edge technology from smartphones to smart home devices. '
                  'Quality electronics with fast shipping.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black.withOpacity(.7),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 14),

                // 🔹 Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // keep your existing behavior to open Products tab in shell
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const AppShell(startIndex: 1),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25355E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Shop Now'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pushNamed(context, '/shell'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFF25355E)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          foregroundColor:
                              isDark ? Colors.white : const Color(0xFF25355E),
                        ),
                        child: const Text('View Deals'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Text(
            'Categories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          // 🔹 Category row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _CategoryBox(icon: Icons.photo_camera_back_outlined, label: 'Photos', bg: Color(0xFFEFF5FF)),
              _CategoryBox(icon: Icons.laptop_mac, label: 'Laptops', bg: Color(0xFFEFF5FF)),
              _CategoryBox(icon: Icons.headphones_outlined, label: 'Audio', bg: Color(0xFFEFF5FF)),
              _CategoryBox(icon: Icons.watch_outlined, label: 'Watches', bg: Color(0xFFEFF5FF)),
            ],
          ),

          const SizedBox(height: 20),
          Text(
            'Featured Products',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          // 🔹 Featured list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: featured.length,
            itemBuilder: (context, index) {
              final p = featured[index];
              return _FeaturedCard(
                product: p,
                details: detailsByName[p.name], // 🔹 pass extras for this product
              );
            },
          ),
        ],
      ),
    );
  }
}

/* ---------- Helper Widgets ---------- */

class _CategoryBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  const _CategoryBox({required this.icon, required this.label, required this.bg});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeController.instance.themeMode.value == ThemeMode.dark;

    return Container(
      width: 74,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x11000000)),
      ),
      child: Column(
        children: [
          Icon(icon, color: isDark ? Colors.white70 : Colors.black87),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black),
          ),
        ],
      ),
    );
  }
}

class _Product {
  final String image;
  final String name;
  final double price;
  final double oldPrice;
  final double rating;
  final int reviews;
  const _Product({
    required this.image,
    required this.name,
    required this.price,
    required this.oldPrice,
    required this.rating,
    required this.reviews,
  });
}

class _FeaturedCard extends StatelessWidget {
  final _Product product;
  final Map<String, dynamic>? details; // 🔹 NEW
  const _FeaturedCard({required this.product, this.details});

  void _openDetails(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/productDetail',
      arguments: {
        'name': product.name,
        'price': product.price,
        'rating': product.rating,
        'image': product.image,
        // pass extras if present (safe to be null)
        'desc': details?['desc'],
        'features': details?['features'],
        'gallery': details?['gallery'],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeController.instance.themeMode.value == ThemeMode.dark;

    final card = Card(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // image (tappable too)
            GestureDetector(
              onTap: () => _openDetails(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  color: Colors.white,
                  alignment: Alignment.center,
                  child: Image.asset(
                    product.image,
                    fit: BoxFit.contain,
                    height: 200,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product.name,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.star, size: 18, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  product.rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '\$${product.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // action row
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _openDetails(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25355E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('View Product'),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _openDetails(context),
                    icon: Icon(
                      Icons.chevron_right,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Make the whole card tappable (optional UX sugar)
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _openDetails(context),
      child: card,
    );
  }
}
