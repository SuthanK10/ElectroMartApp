import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ---------------------------------------------------------------------------
  // 🟢 LIVE SERVER URL
  // ---------------------------------------------------------------------------
  static const String baseUrl =
      'https://electromartlaravel-production.up.railway.app/api';
  static const String storageUrl =
      'https://electromartlaravel-production.up.railway.app/storage';

  // Singleton pattern for easy access
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  // ---------------------------------------------------------------------------
  // 🔐 AUTHENTICATION
  // ---------------------------------------------------------------------------

  Future<bool> login(String email, String password) async {
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
          return true;
        }
      }
      return false;
    } catch (e) {
      print('❌ Login Logic Error: $e');
      return false;
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
      print('Registration Error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // ---------------------------------------------------------------------------
  // 📦 DATA & PRODUCTS (Offline Supported)
  // ---------------------------------------------------------------------------

  Future<List<dynamic>> fetchProducts() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      print('🔹 Fetching products from: $baseUrl/products');
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
        print('❌ Server Error: ${response.statusCode}');
        return _loadCachedProducts(prefs);
      }
    } catch (e) {
      print('⚠️ Network Error (Offline?): $e');
      return _loadCachedProducts(prefs);
    }
  }

  List<dynamic> _loadCachedProducts(SharedPreferences prefs) {
    if (prefs.containsKey('cached_products')) {
      print('📂 Loading products from local cache...');
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
