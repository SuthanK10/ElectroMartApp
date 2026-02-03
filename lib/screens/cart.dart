import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/product.dart';
import '../services/api_service.dart';

/* ============== Simple Cart Store ============== */

class CartItem {
  final Product product;
  int qty;
  CartItem(this.product, {this.qty = 1});

  double get unitPrice => (product.price as num).toDouble();
  double get lineTotal => unitPrice * qty;
}

class CartStore {
  CartStore._();
  static final CartStore instance = CartStore._();

  final ValueNotifier<List<CartItem>> items = ValueNotifier<List<CartItem>>(
    <CartItem>[],
  );

  void add(Product p) {
    final list = [...items.value];
    final i = list.indexWhere(
      (e) => e.product.name == p.name && e.product.image == p.image,
    );
    if (i >= 0) {
      list[i].qty += 1;
    } else {
      list.add(CartItem(p, qty: 1));
    }
    items.value = list;
  }

  void increment(int index) {
    final list = [...items.value];
    list[index].qty += 1;
    items.value = list;
  }

  void decrement(int index) {
    final list = [...items.value];
    if (list[index].qty > 1) {
      list[index].qty -= 1;
    } else {
      list.removeAt(index);
    }
    items.value = list;
  }

  void removeAt(int index) {
    final list = [...items.value]..removeAt(index);
    items.value = list;
  }

  void clear() => items.value = [];

  double get total => items.value.fold(0.0, (sum, e) => sum + e.lineTotal);
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF25355E),
        foregroundColor: Colors.white,
        title: const Text(
          'Cart',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ValueListenableBuilder<List<CartItem>>(
        valueListenable: CartStore.instance.items,
        builder: (context, items, _) {
          if (items.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final e = items[i];
              final p = e.product;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    ApiService().getImageUrl(p.image),
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => const Icon(
                      Icons.broken_image_rounded,
                      size: 24,
                      color: Colors.grey,
                    ),
                  ),
                ),
                title: Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '\$${e.unitPrice.toStringAsFixed(2)} each • '
                  'Line: \$${e.lineTotal.toStringAsFixed(2)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _stepBtn(
                      context,
                      icon: Icons.remove,
                      onTap: () => CartStore.instance.decrement(i),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${e.qty}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    _stepBtn(
                      context,
                      icon: Icons.add,
                      onTap: () => CartStore.instance.increment(i),
                    ),
                    IconButton(
                      tooltip: 'Remove item',
                      onPressed: () => CartStore.instance.removeAt(i),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ValueListenableBuilder<List<CartItem>>(
            valueListenable: CartStore.instance.items,
            builder: (context, items, _) {
              final total = CartStore.instance.total;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Location Sensor Feature
                  if (items.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () async {
                          final pos = await _determinePosition();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Delivery to: ${pos.latitude}, ${pos.longitude}',
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.my_location),
                        label: const Text('Deliver to Current Location'),
                      ),
                    ),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: items.isEmpty
                              ? null
                              : CartStore.instance.clear,
                          child: const Text('Clear Cart'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: items.isEmpty ? null : () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25355E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Checkout • \$${total.toStringAsFixed(2)}',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _stepBtn(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }
}
