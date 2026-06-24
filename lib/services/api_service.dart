import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'logger_service.dart';

import '../config/api_config.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/cart_item_model.dart';
import '../models/banner_model.dart';
import '../models/review_model.dart';
import '../models/address_model.dart';
import '../models/coupon_model.dart';
import '../models/notification_model.dart';

// ─── Token storage key ────────────────────────────────────────────────────────
const _kTokenKey = 'api_auth_token';
const _kUserKey = 'api_auth_user';

// ─── Helpers ─────────────────────────────────────────────────────────────────
Map<String, String> _jsonHeaders([String? token]) => {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

T _decode<T>(http.Response res, T Function(dynamic) mapper) {
  dynamic body;
  try {
    body = jsonDecode(res.body);
  } catch (_) {
    body = res.body;
  }

  if (res.statusCode >= 400) {
    // For server errors avoid surfacing raw DB/server messages to UI.
    if (res.statusCode >= 500) {
      LoggerService.error('API server error: ${res.body}');
      throw ApiException('Server error (${res.statusCode})', res.statusCode);
    }

    final msg = body is Map
        ? (body['error'] ?? body['message'] ?? 'Request failed')
        : 'Request failed';
    throw ApiException(msg.toString(), res.statusCode);
  }

  return mapper(body);
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  const ApiException(this.message, this.statusCode);
  @override
  String toString() => 'ApiException($statusCode): $message';
}

// ─── Auth Model ───────────────────────────────────────────────────────────────
class ApiUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;

  const ApiUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
  });

  factory ApiUser.fromJson(Map<String, dynamic> json) => ApiUser(
        id: json['id']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        firstName: (json['firstName'] ?? json['first_name'] ?? '').toString(),
        lastName: (json['lastName'] ?? json['last_name'] ?? '').toString(),
        role: json['role']?.toString() ?? 'user',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
      };

  String get fullName => '$firstName $lastName'.trim();
}

// ─── ApiService ───────────────────────────────────────────────────────────────
class ApiService {
  // Singleton
  ApiService._();
  static final ApiService instance = ApiService._();

  // In-memory cache
  String? _token;
  ApiUser? _currentUser;

  String? get token => _token;
  ApiUser? get currentUser => _currentUser;
  bool get isLoggedIn => _token != null;

  // ── Init ──────────────────────────────────────────────────────────────────
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_kTokenKey);
    final userJson = prefs.getString(_kUserKey);
    if (userJson != null) {
      _currentUser =
          ApiUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    }
  }

  Future<void> _persist(String token, ApiUser user) async {
    _token = token;
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTokenKey, token);
    await prefs.setString(_kUserKey, jsonEncode(user.toJson()));
  }

  Future<void> _clearPersisted() async {
    _token = null;
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenKey);
    await prefs.remove(_kUserKey);
  }

  // ── Auth ─────────────────────────────────────────────────────────────────
  Future<ApiUser> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: _jsonHeaders(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _decode(res, (body) async {
      final user = ApiUser.fromJson(body['user'] as Map<String, dynamic>);
      await _persist(body['token'] as String, user);
      return user;
    });
  }

  Future<ApiUser> register({
    required String email,
    required String password,
    required String firstName,
    String lastName = '',
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/register'),
      headers: _jsonHeaders(),
      body: jsonEncode({
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
      }),
    );
    return _decode(res, (body) async {
      final user = ApiUser.fromJson(body['user'] as Map<String, dynamic>);
      await _persist(body['token'] as String, user);
      return user;
    });
  }

  Future<void> logout() => _clearPersisted();

  Future<ApiUser?> refreshUser() async {
    if (_token == null) return null;
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/auth/me'),
        headers: _jsonHeaders(_token),
      );
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        _currentUser = ApiUser.fromJson(json);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_kUserKey, jsonEncode(_currentUser!.toJson()));
        return _currentUser;
      }
      // Token invalid – clear it
      await _clearPersisted();
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── Products ─────────────────────────────────────────────────────────────
  Future<List<ProductModel>> getProducts(
      {String? categoryId, String? categoryName}) async {
    final uri =
        Uri.parse('${ApiConfig.baseUrl}/products').replace(queryParameters: {
      if (categoryId != null) 'categoryId': categoryId,
      if (categoryName != null) 'categoryName': categoryName,
      'limit': '100',
    });
    final res = await http.get(uri, headers: _jsonHeaders(_token));
    return _decode(
        res,
        (body) => (body['data'] as List)
            .map((e) => ProductModel.fromJson(_flatProduct(e)))
            .toList());
  }

  Future<List<ProductModel>> getTrendingProducts() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/products/trending'),
      headers: _jsonHeaders(_token),
    );
    return _decode(
        res,
        (body) => (body['data'] as List)
            .map((e) => ProductModel.fromJson(_flatProduct(e)))
            .toList());
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/products/search')
        .replace(queryParameters: {'q': query});
    final res = await http.get(uri, headers: _jsonHeaders(_token));
    return _decode(
        res,
        (body) => (body['data'] as List)
            .map((e) => ProductModel.fromJson(_flatProduct(e)))
            .toList());
  }

  Future<List<ProductModel>> getRelatedProducts({
    required String productId,
    String? subcategoryId,
    String? categoryId,
    int limit = 6,
  }) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/products/$productId/related'),
      headers: _jsonHeaders(_token),
    );
    if (res.statusCode == 404) return [];
    return _decode(
        res,
        (body) => (body['data'] as List)
            .map((e) => ProductModel.fromJson(_flatProduct(e)))
            .toList());
  }

  // ── Categories ────────────────────────────────────────────────────────────
  Future<List<CategoryModel>> getCategories() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/categories'),
      headers: _jsonHeaders(_token),
    );
    return _decode(
        res,
        (body) => (body['data'] as List)
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList());
  }

  // ── Banners ───────────────────────────────────────────────────────────────
  Future<List<BannerModel>> getBanners() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/banners'),
      headers: _jsonHeaders(_token),
    );
    return _decode(
        res,
        (body) => (body['data'] as List)
            .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
            .toList());
  }

  // ── Settings ──────────────────────────────────────────────────────────────
  Future<Map<String, String>> getSettings() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/settings'),
      headers: _jsonHeaders(_token),
    );
    return _decode(res, (body) {
      final data =
          body['data'] as Map<String, dynamic>? ?? body as Map<String, dynamic>;
      return data.map((k, v) => MapEntry(k, v?.toString() ?? ''));
    });
  }

  // ── FAQs ──────────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getFaqs() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/faqs'),
      headers: _jsonHeaders(_token),
    );
    return _decode(
        res, (body) => List<Map<String, dynamic>>.from(body['data'] as List));
  }

  // ── Profile ───────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getProfile() async {
    if (_token == null) return null;
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/profile'),
      headers: _jsonHeaders(_token),
    );
    if (res.statusCode == 404) return null;
    return _decode(res, (body) => body['data'] as Map<String, dynamic>?);
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/profile'),
      headers: _jsonHeaders(_token),
      body: jsonEncode(data),
    );
  }

  // ── Addresses ─────────────────────────────────────────────────────────────
  Future<List<AddressModel>> getAddresses() async {
    if (_token == null) return [];
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/addresses'),
      headers: _jsonHeaders(_token),
    );
    return _decode(
        res,
        (body) => (body['data'] as List)
            .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
            .toList());
  }

  Future<void> addAddress(AddressModel address) async {
    await http.post(
      Uri.parse('${ApiConfig.baseUrl}/addresses'),
      headers: _jsonHeaders(_token),
      body: jsonEncode(address.toJson()),
    );
  }

  Future<void> updateAddress(AddressModel address) async {
    if (address.id == null) return;
    await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/addresses/${address.id}'),
      headers: _jsonHeaders(_token),
      body: jsonEncode(address.toJson()),
    );
  }

  Future<void> deleteAddress(String id) async {
    await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/addresses/$id'),
      headers: _jsonHeaders(_token),
    );
  }

  // ── Cart ──────────────────────────────────────────────────────────────────
  Future<List<CartItemModel>> getCart() async {
    if (_token == null) return [];
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/cart'),
      headers: _jsonHeaders(_token),
    );
    return _decode(res, (body) {
      final items = body['data'] as List? ?? [];
      return items.map((e) {
        // Backend uses row_to_json(p.*) AS products
        final rawProduct =
            (e['products'] ?? e['product']) as Map<String, dynamic>;
        final product = ProductModel.fromJson(_flatProduct(rawProduct));
        final qty = e['quantity'];
        return CartItemModel(
          id: e['id'].toString(),
          product: product,
          quantity: qty is int ? qty : int.tryParse(qty.toString()) ?? 1,
        );
      }).toList();
    });
  }

  Future<void> addToCart(String productId, int quantity) async {
    await http.post(
      Uri.parse('${ApiConfig.baseUrl}/cart'),
      headers: _jsonHeaders(_token),
      body: jsonEncode({'productId': productId, 'quantity': quantity}),
    );
  }

  Future<void> updateCartQuantity(String cartItemId, int quantity) async {
    await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/cart/$cartItemId'),
      headers: _jsonHeaders(_token),
      body: jsonEncode({'quantity': quantity}),
    );
  }

  Future<void> removeFromCart(String cartItemId) async {
    await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/cart/$cartItemId'),
      headers: _jsonHeaders(_token),
    );
  }

  Future<void> clearCart() async {
    if (_token == null) return;
    await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/cart'),
      headers: _jsonHeaders(_token),
    );
  }

  // ── Wishlist ──────────────────────────────────────────────────────────────
  Future<List<ProductModel>> getWishlist() async {
    if (_token == null) return [];
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/wishlist'),
      headers: _jsonHeaders(_token),
    );
    return _decode(
        res,
        (body) => (body['data'] as List? ?? [])
            .map((e) => ProductModel.fromJson(_flatProduct(
                // Backend uses row_to_json(p.*) AS products
                (e['products'] ?? e['product'] ?? e) as Map<String, dynamic>)))
            .toList());
  }

  Future<void> addToWishlist(String productId) async {
    await http.post(
      Uri.parse('${ApiConfig.baseUrl}/wishlist'),
      headers: _jsonHeaders(_token),
      body: jsonEncode({'productId': productId}),
    );
  }

  Future<void> removeFromWishlist(String productId) async {
    await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/wishlist/$productId'),
      headers: _jsonHeaders(_token),
    );
  }

  // ── Orders ────────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getOrders() async {
    if (_token == null) return [];
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/orders'),
      headers: _jsonHeaders(_token),
    );
    return _decode(res,
        (body) => List<Map<String, dynamic>>.from(body['data'] as List? ?? []));
  }

  Future<void> placeOrder({
    required String addressId,
    required double total,
    required List<CartItemModel> items,
    String paymentMethod = 'Cash on Delivery',
    String? razorpayPaymentId,
    String? couponId,
    double couponDiscount = 0,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/orders'),
      headers: _jsonHeaders(_token),
      body: jsonEncode({
        'addressId': addressId,
        'total': total,
        'paymentMethod': paymentMethod,
        if (razorpayPaymentId != null) 'razorpayPaymentId': razorpayPaymentId,
        if (couponId != null) 'couponId': couponId,
        'couponDiscount': couponDiscount,
        'items': items
            .map((i) => {
                  'productId': i.product.id,
                  'quantity': i.quantity,
                  'price': i.product.priceAfterDiscount ?? i.product.price,
                })
            .toList(),
      }),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      throw ApiException(
          body['error']?.toString() ?? 'Failed to place order', res.statusCode);
    }
  }

  // ── Razorpay ──────────────────────────────────────────────────────────────

  /// Creates a Razorpay order via the Express backend (which calls Razorpay API).
  /// Returns { razorpay_order_id, key_id, amount, currency }.
  Future<Map<String, dynamic>> createRazorpayOrder({
    required double totalAmount,
    String? receipt,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/payments/create-razorpay-order'),
      headers: _jsonHeaders(_token),
      body: jsonEncode({
        'amount': totalAmount,
        'currency': 'INR',
        if (receipt != null) 'receipt': receipt,
      }),
    );
    return _decode(res, (body) => body as Map<String, dynamic>);
  }

  /// Verifies the Razorpay payment signature on the backend and places the order.
  Future<void> verifyRazorpayAndPlaceOrder({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String addressId,
    required double total,
    required List<CartItemModel> items,
    String? couponId,
    double couponDiscount = 0,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/payments/verify-razorpay'),
      headers: _jsonHeaders(_token),
      body: jsonEncode({
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
        'addressId': addressId,
        'total': total,
        if (couponId != null) 'couponId': couponId,
        'couponDiscount': couponDiscount,
        'items': items
            .map((i) => {
                  'productId': i.product.id,
                  'quantity': i.quantity,
                  'price': i.product.priceAfterDiscount ?? i.product.price,
                })
            .toList(),
      }),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      throw ApiException(
          body['error']?.toString() ?? 'Payment verification failed',
          res.statusCode);
    }
  }

  // ── Order sync ────────────────────────────────────────────────────────────

  /// Fetches the latest order status from the backend.
  /// Returns a map shaped like: { current_status, activities, label_url }
  /// so that OrderTrackingScreen can use it directly.
  Future<Map<String, dynamic>?> syncOrder(String orderId) async {
    if (_token == null) return null;
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/orders/$orderId/sync'),
      headers: _jsonHeaders(_token),
    );
    if (res.statusCode == 404) return null;
    if (res.statusCode != 200) return null;
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final order = body['data'] as Map<String, dynamic>?;
    if (order == null) return null;
    return {
      'current_status': order['courier_status'] ?? order['status'] ?? '',
      'activities': <Map<String, dynamic>>[],
      'label_url': order['shipping_label_url'],
    };
  }

  // ── Avatar upload ─────────────────────────────────────────────────────────

  /// Converts image bytes to a base64 data URL and saves it to the profile.
  /// Works on both mobile and web — the caller passes raw bytes.
  Future<String?> uploadAvatar(Uint8List bytes, String fileName) async {
    if (_token == null) return null;
    try {
      final ext = fileName.split('.').last.toLowerCase();
      final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';
      final dataUrl = 'data:$mimeType;base64,${base64Encode(bytes)}';
      await updateProfile({'avatar_url': dataUrl});
      return dataUrl;
    } catch (_) {
      return null;
    }
  }

  // ── Notifications ─────────────────────────────────────────────────────────

  Future<List<NotificationModel>> getNotifications() async {
    if (_token == null) return [];
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/notifications'),
        headers: _jsonHeaders(_token),
      );
      if (res.statusCode != 200) return [];
      return _decode(
          res,
          (body) => (body['data'] as List? ?? [])
              .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
              .toList());
    } catch (_) {
      return [];
    }
  }

  Future<void> markNotificationRead(String id) async {
    if (_token == null) return;
    await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/notifications/$id/read'),
      headers: _jsonHeaders(_token),
    );
  }

  Future<void> markAllNotificationsRead() async {
    if (_token == null) return;
    await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/notifications/read-all'),
      headers: _jsonHeaders(_token),
    );
  }

  Future<int> getUnreadNotificationCount() async {
    if (_token == null) return 0;
    try {
      final notifications = await getNotifications();
      return notifications.where((n) => !n.isRead).length;
    } catch (_) {
      return 0;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    await http.post(
      Uri.parse('${ApiConfig.baseUrl}/orders/$orderId/cancel'),
      headers: _jsonHeaders(_token),
    );
  }

  Future<void> requestReturn(String orderId) async {
    await http.post(
      Uri.parse('${ApiConfig.baseUrl}/orders/$orderId/return'),
      headers: _jsonHeaders(_token),
    );
  }

  Future<Map<String, int>> getOrderCounts() async {
    final orders = await getOrders();
    final counts = <String, int>{};
    for (final o in orders) {
      final status = (o['status'] ?? '').toString().toLowerCase();
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }

  // ── Reviews ───────────────────────────────────────────────────────────────
  Future<List<ReviewModel>> getProductReviews(String productId) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/reviews/$productId'),
      headers: _jsonHeaders(_token),
    );
    return _decode(
        res,
        (body) => (body['data'] as List? ?? [])
            .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
            .toList());
  }

  Future<void> addReview(String productId, int rating, String comment) async {
    await http.post(
      Uri.parse('${ApiConfig.baseUrl}/reviews'),
      headers: _jsonHeaders(_token),
      body: jsonEncode(
          {'productId': productId, 'rating': rating, 'comment': comment}),
    );
  }

  // ── Search history ────────────────────────────────────────────────────────
  Future<List<String>> getSearchHistory() async {
    if (_token == null) return [];
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/search/history'),
      headers: _jsonHeaders(_token),
    );
    return _decode(
        res,
        (body) => (body['data'] as List? ?? [])
            .map((e) => e['query'].toString())
            .toList());
  }

  Future<void> saveSearchQuery(String query) async {
    if (_token == null || query.trim().isEmpty) return;
    await http.post(
      Uri.parse('${ApiConfig.baseUrl}/search/history'),
      headers: _jsonHeaders(_token),
      body: jsonEncode({'query': query}),
    );
  }

  Future<void> clearSearchHistory() async {
    if (_token == null) return;
    await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/search/history'),
      headers: _jsonHeaders(_token),
    );
  }

  // ── Recently viewed ───────────────────────────────────────────────────────
  Future<List<ProductModel>> getRecentlyViewed() async {
    if (_token == null) return [];
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/search/recently-viewed'),
      headers: _jsonHeaders(_token),
    );
    return _decode(
        res,
        (body) => (body['data'] as List? ?? [])
            .map((e) => ProductModel.fromJson(_flatProduct(
                // Backend uses row_to_json(p.*) AS products
                (e['products'] ?? e['product'] ?? e) as Map<String, dynamic>)))
            .toList());
  }

  Future<void> saveRecentlyViewed(String productId) async {
    if (_token == null) return;
    await http.post(
      Uri.parse('${ApiConfig.baseUrl}/search/recently-viewed'),
      headers: _jsonHeaders(_token),
      body: jsonEncode({'productId': productId}),
    );
  }

  Future<void> clearRecentlyViewed() async {
    if (_token == null) return;
    // No endpoint in the backend; no-op
  }

  // ── Coupons ───────────────────────────────────────────────────────────────
  Future<CouponModel?> validateCoupon(String code) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/coupons/validate'),
        headers: _jsonHeaders(_token),
        body: jsonEncode({'code': code}),
      );
      if (res.statusCode != 200) return null;
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return CouponModel.fromJson(
          body['data'] as Map<String, dynamic>? ?? body);
    } catch (_) {
      return null;
    }
  }

  // ── Support tickets ───────────────────────────────────────────────────────
  Future<String?> createSupportTicket(String message, {String? subject}) async {
    if (_token == null) return null;
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/support/tickets'),
      headers: _jsonHeaders(_token),
      body: jsonEncode(
          {'message': message, if (subject != null) 'subject': subject}),
    );
    return _decode(res, (body) => body['data']?['id']?.toString());
  }

  Future<List<Map<String, dynamic>>> getUserSupportTickets() async {
    if (_token == null) return [];
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/support/tickets'),
      headers: _jsonHeaders(_token),
    );
    return _decode(res,
        (body) => List<Map<String, dynamic>>.from(body['data'] as List? ?? []));
  }

  Future<List<Map<String, dynamic>>> getSupportMessages(String ticketId) async {
    if (_token == null) return [];
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/support/tickets/$ticketId/messages'),
      headers: _jsonHeaders(_token),
    );
    return _decode(res,
        (body) => List<Map<String, dynamic>>.from(body['data'] as List? ?? []));
  }

  Future<void> sendSupportMessage(String ticketId, String message,
      {bool isAdmin = false}) async {
    if (_token == null) return;
    await http.post(
      Uri.parse('${ApiConfig.baseUrl}/support/tickets/$ticketId/messages'),
      headers: _jsonHeaders(_token),
      body: jsonEncode({'message': message}),
    );
  }

  // ── Delivery estimate ─────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> checkDeliveryEstimate(String pincode) async {
    // Falls back to Supabase RPC; this endpoint is not on Express backend yet
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Normalises flat Express product rows into the shape ProductModel.fromJson expects.
  static Map<String, dynamic> _flatProduct(Map<String, dynamic> p) {
    return {
      ...p,
      // Express returns flat category_title / sub_category_title.
      // Wrap them so ProductModel.fromJson can find them in both formats.
      if (p['category_title'] != null && p['categories'] == null)
        'categories': {'title': p['category_title']},
      if (p['sub_category_title'] != null && p['sub_categories'] == null)
        'sub_categories': {'title': p['sub_category_title']},
    };
  }
}
