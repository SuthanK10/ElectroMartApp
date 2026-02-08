import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

// ... (existing imports)

// existing code ...

import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class CartItem {
  final Product product;
  int qty;
  CartItem(this.product, {this.qty = 1});

  double get unitPrice => (product.price as num).toDouble();
  double get lineTotal => unitPrice * qty;
}

// 🔹 PROVIDER: Extending ChangeNotifier to showcase external state management
class CartStore extends ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  // --- Cart Operations ---
  void add(Product p) {
    final i = _items.indexWhere(
      (e) => e.product.name == p.name && e.product.image == p.image,
    );
    if (i >= 0) {
      _items[i].qty += 1;
    } else {
      _items.add(CartItem(p, qty: 1));
    }
    notifyListeners();
  }

  void increment(int index) {
    _items[index].qty += 1;
    notifyListeners();
  }

  void decrement(int index) {
    if (_items[index].qty > 1) {
      _items[index].qty -= 1;
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  void removeAt(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void clear() {
    _items = [];
    notifyListeners();
  }

  double get total => _items.fold(0.0, (sum, e) => sum + e.lineTotal);

  // --- Local Order History Logic ---
  Future<String?> checkout() async {
    if (_items.isEmpty) return "Cart is empty";

    // Simulate processing
    await Future.delayed(const Duration(seconds: 1));

    // Save locally
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('order_history');
    List<dynamic> history = historyJson != null ? jsonDecode(historyJson) : [];

    final newOrder = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'date': DateTime.now().toIso8601String(),
      'total': total,
      'items': _items
          .map(
            (e) => {
              'name': e.product.name,
              'image': e.product.image,
              'price': e.unitPrice,
              'qty': e.qty,
            },
          )
          .toList(),
    };

    history.insert(0, newOrder); // Add to top
    await prefs.setString('order_history', jsonEncode(history));

    clear();
    return null; // Success
  }
}

// Note: CartStore class is defined above in this file (or move to separate file if preferred)

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isCheckingOut = false;

  // Accelerometer subscription
  StreamSubscription<UserAccelerometerEvent>? _accelerometerSubscription;
  DateTime _lastShakeTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }
    });

    // Initialize Accelerometer for Shake Detection
    _initShakeDetection();
  }

  void _initShakeDetection() {
    _accelerometerSubscription =
        userAccelerometerEventStream(
          samplingPeriod: SensorInterval.gameInterval,
        ).listen((UserAccelerometerEvent event) {
          // Simple shake detection logic
          double acceleration = event.x.abs() + event.y.abs() + event.z.abs();
          if (acceleration > 30) {
            // Threshold for shake
            final now = DateTime.now();
            if (now.difference(_lastShakeTime) > const Duration(seconds: 2)) {
              _lastShakeTime = now;
              _handleShake();
            }
          }
        });
  }

  void _handleShake() {
    if (!mounted) return;

    // Logic to clear cart on shake
    final cart = Provider.of<CartStore>(context, listen: false);
    if (cart.items.isNotEmpty) {
      cart.clear(); // Clear the cart
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cart cleared by shake! 📳'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

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
      // 🔹 PROVIDER: Using Consumer to listen to changes
      body: Consumer<CartStore>(
        builder: (context, cart, _) {
          final items = cart.items;

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
                      onTap: () => cart.decrement(i),
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
                      onTap: () => cart.increment(i),
                    ),
                    IconButton(
                      tooltip: 'Remove item',
                      onPressed: () => cart.removeAt(i),
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
          child: Consumer<CartStore>(
            builder: (context, cart, _) {
              final items = cart.items;
              final total = cart.total;
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
                          try {
                            final pos = await _determinePosition();

                            // Get address from coordinates
                            List<Placemark> placemarks =
                                await placemarkFromCoordinates(
                                  pos.latitude,
                                  pos.longitude,
                                );

                            String locationText =
                                '${pos.latitude}, ${pos.longitude}';

                            if (placemarks.isNotEmpty) {
                              final place = placemarks.first;
                              // e.g. "Mountain View, United States"
                              final city =
                                  place.locality ??
                                  place.subAdministrativeArea ??
                                  '';
                              final country = place.country ?? '';

                              if (city.isNotEmpty) {
                                locationText = '$city, $country\n$locationText';
                              }
                            }

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Delivery to: $locationText'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error getting location: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
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
                          onPressed: items.isEmpty || _isCheckingOut
                              ? null
                              : cart.clear,
                          child: const Text('Clear Cart'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: items.isEmpty || _isCheckingOut
                              ? null
                              : () async {
                                  setState(() => _isCheckingOut = true);
                                  final error = await cart.checkout();
                                  setState(() => _isCheckingOut = false);

                                  if (!context.mounted) return;

                                  if (error != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(error),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 60,
                                        ),
                                        content: const Text(
                                          'Order Placed Successfully!',
                                          textAlign: TextAlign.center,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(
                                                ctx,
                                              ); // close dialog
                                              Navigator.pushReplacementNamed(
                                                context,
                                                '/',
                                              ); // go home
                                            },
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25355E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isCheckingOut
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
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
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
