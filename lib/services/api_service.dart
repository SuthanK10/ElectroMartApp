import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';

class ApiService {
  // ---------------------------------------------------------------------------
  // 🟢 SERVER URL (Loaded from config.dart)
  // ---------------------------------------------------------------------------
  static const String baseUrl = AppConfig.baseUrl;
  static const String storageUrl = AppConfig.storageUrl;

  // Singleton pattern for easy access
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  bool get isAuthenticated => _token != null;

  // ---------------------------------------------------------------------------
  // 🔐 AUTHENTICATION
  // ---------------------------------------------------------------------------

  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'device_name': 'mobile_app',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'] ?? data['access_token'];

        if (_token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', _token!);
          return null;
        }
        return 'Login successful but no token received.';
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return errorData['message'] ??
              errorData['error'] ??
              'Login failed (${response.statusCode})';
        } catch (_) {
          return 'Login failed (${response.statusCode})';
        }
      }
    } catch (e) {
      debugPrint('❌ Login Logic Error: $e');
      return 'Connection Error: $e';
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'device_name': 'mobile_app',
        }),
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint('Registration Error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // ---------------------------------------------------------------------------
  // 👤 USER PROFILE
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>?> fetchUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('❌ Fetch User Error: $e');
    }
    return null;
  }

  Future<String?> updateProfile(String name, String email) async {
    try {
      // Trying standard Laravel resource update or specific endpoint
      // Using POST with _method=PUT is safer for some PHP configs, but standard PUT should work.
      final response = await http.put(
        Uri.parse(
          '$baseUrl/user/profile-information',
        ), // Standard Fortify/Breeze
        // If 404, we might need to fallback to '$baseUrl/user'
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'name': name, 'email': email}),
      );

      // Fallback if the standard profile-information route doesn't exist
      if (response.statusCode == 404) {
        return _updateProfileFallback(name, email);
      }

      if (response.statusCode == 200 || response.statusCode == 202) {
        return null; // Success
      } else {
        final data = jsonDecode(response.body);
        return data['message'] ?? 'Update failed';
      }
    } catch (e) {
      return 'Connection Error: $e';
    }
  }

  Future<String?> _updateProfileFallback(String name, String email) async {
    final response = await http.put(
      Uri.parse('$baseUrl/user'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      },
      body: jsonEncode({'name': name, 'email': email}),
    );

    if (response.statusCode == 200) {
      return null;
    }
    return 'Update failed (${response.statusCode})';
  }

  // ---------------------------------------------------------------------------
  // 🛒 ORDERS
  // ---------------------------------------------------------------------------

  Future<String?> createOrder(
    double total,
    List<Map<String, dynamic>> items,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/checkout'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'total_price': total, 'items': items}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return null; // Success
      } else {
        debugPrint('❌ Order Failed: ${response.statusCode} - ${response.body}');
        try {
          final errorData = jsonDecode(response.body);
          return errorData['message'] ??
              'Order failed (${response.statusCode})';
        } catch (_) {
          return 'Order failed (${response.statusCode})';
        }
      }
    } catch (e) {
      debugPrint('❌ Order Exception: $e');
      return 'Connection Error: $e';
    }
  }

  // ---------------------------------------------------------------------------
  // 📦 DATA & PRODUCTS (Offline Supported)
  // ---------------------------------------------------------------------------

  Future<List<dynamic>> fetchProducts() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      debugPrint('🔹 Fetching products from: $baseUrl/products');
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: {
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Save to local storage for offline use
        await prefs.setString('cached_products', response.body);

        // Laravel Resources usually wrap lists in 'data'
        if (data is Map && data.containsKey('data')) {
          return data['data'];
        } else if (data is List) {
          return data;
        }
        return [];
      } else {
        debugPrint('❌ Server Error: ${response.statusCode}');
        return _loadCachedProducts(prefs);
      }
    } catch (e) {
      debugPrint('⚠️ Network Error (Offline?): $e');
      return _loadCachedProducts(prefs);
    }
  }

  List<dynamic> _loadCachedProducts(SharedPreferences prefs) {
    if (prefs.containsKey('cached_products')) {
      debugPrint('📂 Loading products from local cache...');
      final cachedString = prefs.getString('cached_products')!;
      final data = jsonDecode(cachedString);
      if (data is Map && data.containsKey('data')) {
        return data['data'];
      } else if (data is List) {
        return data;
      }
    }
    return [];
  }

  /// Helper to fix image URLs (converts relative paths to absolute, fixes localhost/http issues)
  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return 'https://placehold.co/600x400';

    // 🚨 BUG FIX: The backend seeder often puts FULL URLs (https://unsplash...) into the DB.
    // The ProductResource then wraps it in asset('storage/...') resulting in:
    // "https://site.com/storage/https://unsplash.com/..."
    if (path.contains('/storage/http')) {
      final split = path.split('/storage/');
      if (split.length > 1) {
        return split[1];
      }
    }

    // 1. Fix "localhost" or '10.0.2.2' leaking from backend (common in dev/prod mix)
    String fixedUrl = path;
    if (path.contains('localhost') || path.contains('127.0.0.1')) {
      final uri = Uri.parse(path);
      fixedUrl = '$storageUrl/${uri.path.replaceFirst('/storage/', '')}';
    }

    // 2. If it's already a full URL
    if (fixedUrl.startsWith('http')) {
      if (!fixedUrl.contains('10.0.2.2')) {
        return fixedUrl.replaceFirst('http://', 'https://');
      }
      return fixedUrl;
    }

    // 3. Handle relative paths
    final cleanPath = fixedUrl.startsWith('/')
        ? fixedUrl.substring(1)
        : fixedUrl;
    return '$storageUrl/$cleanPath';
  }
}
