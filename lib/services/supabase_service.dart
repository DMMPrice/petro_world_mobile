import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/cart_item_model.dart';
import '../models/banner_model.dart';
import '../models/review_model.dart';
import '../models/address_model.dart';
import '../models/coupon_model.dart';

class SupabaseService {
  static final client = Supabase.instance.client;

  // --- Categories ---
  static Future<List<CategoryModel>> getCategories() async {
    final response = await client
        .from('categories')
        .select('*, sub_categories(*)');
    return (response as List).map((json) => CategoryModel.fromJson(json)).toList();
  }

  // --- Products ---
  static Future<List<ProductModel>> getProducts({String? categoryId, String? categoryName}) async {
    var query = client.from('products').select('*, categories(*), sub_categories(*)');
    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }
    if (categoryName != null) {
      query = query.eq('categories.title', categoryName);
    }
    final response = await query;
    return (response as List).map((json) => ProductModel.fromJson(json)).toList();
  }

  static Future<List<ProductModel>> searchProducts(String query) async {
    final response = await client
        .from('products')
        .select('*, categories(*), sub_categories(*)')
        .or('title.ilike.%$query%,brand_name.ilike.%$query%');
    return (response as List).map((json) => ProductModel.fromJson(json)).toList();
  }

  static Future<List<ProductModel>> getTrendingProducts() async {
    final response = await client
        .from('products')
        .select('*, categories(*), sub_categories(*)')
        .limit(10)
        .order('created_at', ascending: false);
    return (response as List).map((json) => ProductModel.fromJson(json)).toList();
  }

  // --- User Profile ---
  static Future<Map<String, dynamic>?> getProfile() async {
    final user = client.auth.currentUser;
    if (user == null) return null;
    return await client.from('profiles').select('*').eq('id', user.id).maybeSingle();
  }

  static Future<void> updateProfile(Map<String, dynamic> data) async {
    final user = client.auth.currentUser;
    if (user == null) return;
    await client.from('profiles').upsert({'id': user.id, ...data});
  }

  static Future<String?> uploadAvatar(dynamic file, String fileName) async {
    final user = client.auth.currentUser;
    if (user == null) return null;

    final path = '${user.id}/$fileName';
    
    await client.storage.from('avatars').upload(
      path,
      file,
      fileOptions: const FileOptions(upsert: true),
    );

    return client.storage.from('avatars').getPublicUrl(path);
  }

  // --- Addresses ---
  static Future<List<AddressModel>> getAddresses() async {
    final user = client.auth.currentUser;
    if (user == null) return [];
    final response = await client.from('addresses').select('*').eq('user_id', user.id).order('created_at', ascending: false);
    return (response as List).map((json) => AddressModel.fromJson(json)).toList();
  }

  static Future<void> addAddress(AddressModel address) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    
    // If this is the first address or set as default, reset others
    if (address.isDefault) {
      await client.from('addresses').update({'is_default': false}).eq('user_id', user.id);
    }

    await client.from('addresses').insert({
      'user_id': user.id,
      ...address.toJson(),
    });
  }

  static Future<void> updateAddress(AddressModel address) async {
    if (address.id == null) return;
    
    if (address.isDefault) {
      final user = client.auth.currentUser;
      if (user != null) {
        await client.from('addresses').update({'is_default': false}).eq('user_id', user.id);
      }
    }

    await client.from('addresses').update(address.toJson()).eq('id', address.id!);
  }

  static Future<void> deleteAddress(String id) async {
    await client.from('addresses').delete().eq('id', id);
  }

  // --- Orders ---
  static Future<List<Map<String, dynamic>>> getOrders() async {
    final user = client.auth.currentUser;
    if (user == null) return [];
    return await client
        .from('orders')
        .select(
          '*, order_items(*, products(*)), addresses(*)',
        )
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
  }

  /// Sync a single order's latest status from Shiprocket.
  /// Called when user opens the tracking screen.
  static Future<Map<String, dynamic>?> syncOrder(String orderId) async {
    final user = client.auth.currentUser;
    if (user == null) return null;

    // Fetch shipment_id + tracking_number from DB
    final order = await client
        .from('orders')
        .select('id, shipment_id, tracking_number')
        .eq('id', orderId)
        .eq('user_id', user.id)
        .maybeSingle();

    if (order == null) return null;
    if (order['shipment_id'] == null && order['tracking_number'] == null) return null;

    try {
      final response = await client.functions.invoke(
        'shiprocket-core/sync',
        body: {
          'order_id':        orderId,
          'shipment_id':     order['shipment_id'],
          'tracking_number': order['tracking_number'],
        },
      );
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('Sync error (non-fatal): $e');
      return null;
    }
  }

  /// Cancel an order. Cancels on Shiprocket too if already pushed.
  static Future<void> cancelOrder(String orderId) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    try {
      await client.functions.invoke(
        'shiprocket-core/cancel',
        body: {'order_id': orderId, 'is_return': false},
      );
    } catch (e) {
      // Edge function failed — update DB directly as fallback
      await client.from('orders').update({'status': 'canceled'}).eq('id', orderId);
      rethrow;
    }
  }

  /// Request a return. Marks order as returned on Shiprocket too.
  static Future<void> requestReturn(String orderId) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    try {
      await client.functions.invoke(
        'shiprocket-core/cancel',
        body: {'order_id': orderId, 'is_return': true},
      );
    } catch (e) {
      await client.from('orders').update({'status': 'returned'}).eq('id', orderId);
      rethrow;
    }
  }


  static Future<void> placeOrder({
    required String addressId,
    required double total,
    required List<CartItemModel> items,
    String paymentMethod = "Cash on Delivery",
    String? razorpayPaymentId,
    String? couponId,
    double couponDiscount = 0,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) return;

    final orderNumber = "PW-${DateTime.now().millisecondsSinceEpoch}";

    // 1. Create order
    final List<dynamic> orderResponse = await client.from('orders').insert({
      'user_id': user.id,
      'address_id': addressId,
      'total_amount': total,
      'status': 'ordered',
      'order_number': orderNumber,
      'payment_method': paymentMethod,
      if (razorpayPaymentId != null) 'razorpay_payment_id': razorpayPaymentId,
      if (couponId != null) 'coupon_id': couponId,
      'coupon_discount': couponDiscount,
    }).select();

    if (orderResponse.isEmpty) throw Exception("Failed to create order");
    
    final orderId = orderResponse[0]['id'];

    // 2. Create order items and decrement stock
    final List<Map<String, dynamic>> orderItems = items.map((item) => {
      'order_id': orderId,
      'product_id': item.product.id,
      'quantity': item.quantity,
      'price_at_purchase': item.product.priceAfterDiscount ?? item.product.price,
    }).toList();

    await client.from('order_items').insert(orderItems);

    // Atomic decrement of stock_quantity for each product
    for (final item in items) {
      try {
        await client.rpc('decrement_stock', params: {
          'p_product_id': item.product.id,
          'p_quantity': item.quantity,
        });
      } catch (e) {
        // Fallback to manual update if RPC fails
        try {
          final productData = await client.from('products').select('stock_quantity').eq('id', item.product.id).single();
          if (productData != null) {
            final int currentStock = productData['stock_quantity'] as int;
            await client.from('products').update({
              'stock_quantity': (currentStock - item.quantity).clamp(0, 999999)
            }).eq('id', item.product.id);
          }
        } catch (innerE) {
          print('Failed to decrement stock for ${item.product.id}: $innerE');
        }
      }
    }
    
    // 3. Push to Shiprocket automatically
    try {
      await client.functions.invoke('shiprocket-core/create', body: {
        'order_id': orderId,
      });
    } catch (e) {
      print("Shiprocket Auto-Push Error: $e");
    }

    // 4. Clear cart
    await clearCart();
  }

  /// Create a Razorpay order on the server. Returns razorpay_order_id, key_id, amount.
  static Future<Map<String, dynamic>> createRazorpayOrder({
    required double totalAmount,
    required String receipt,
  }) async {
    final amountPaise = (totalAmount * 100).round();
    final response = await client.functions.invoke(
      'razorpay-checkout/create-order',
      body: {
        'amount_paise': amountPaise,
        'receipt': receipt,
        'notes': {'source': 'PetroWorld App'},
      },
    );
    if (response.data == null) {
      throw Exception('Failed to create Razorpay order');
    }
    final data = response.data as Map<String, dynamic>;
    if (data['error'] != null) {
      throw Exception(data['error'].toString());
    }
    return data;
  }

  /// Verify Razorpay payment signature on the server, then place the order.
  /// Returns the internal order number on success.
  static Future<Map<String, dynamic>> verifyRazorpayAndPlaceOrder({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String addressId,
    required double total,
    required List<CartItemModel> items,
    String? couponId,
    double couponDiscount = 0,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    final response = await client.functions.invoke(
      'razorpay-checkout/verify-payment',
      body: {
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
        'address_id': addressId,
        'total': total,
        'items': items.map((i) => {
          'product_id': i.product.id,
          'quantity': i.quantity,
          'price_at_purchase': i.product.priceAfterDiscount ?? i.product.price,
        }).toList(),
        if (couponId != null) 'coupon_id': couponId,
        'coupon_discount': couponDiscount,
      },
    );

    if (response.data == null) throw Exception('Payment verification failed');
    final data = response.data as Map<String, dynamic>;
    if (data['error'] != null) throw Exception(data['error'].toString());

    // Clear cart locally after server confirms
    await clearCart();
    return data;
  }


  static Future<Map<String, int>> getOrderCounts() async {
    final user = client.auth.currentUser;
    if (user == null) return {};

    final response = await client
        .from('orders')
        .select('status')
        .eq('user_id', user.id);
    
    final orders = response as List;
    final Map<String, int> counts = {};
    
    for (var order in orders) {
      String status = order['status'].toString().toLowerCase();
      // Remove 'orderstatus.' prefix if it exists
      if (status.startsWith('orderstatus.')) {
        status = status.replaceFirst('orderstatus.', '');
      }
      counts[status] = (counts[status] ?? 0) + 1;
    }
    
    return counts;
  }

  // --- Wishlist ---
  static Future<List<ProductModel>> getWishlist() async {
    final user = client.auth.currentUser;
    if (user == null) return [];
    
    try {
      final response = await client
          .from('wishlists')
          .select('products(*)')
          .eq('user_id', user.id);
      
      return (response as List).map((json) {
        final productData = json['products'];
        if (productData == null) return null;
        if (productData is List) {
          return productData.isNotEmpty ? ProductModel.fromJson(productData[0]) : null;
        }
        return ProductModel.fromJson(productData);
      }).whereType<ProductModel>().toList();
    } catch (e) {
      print('Error fetching wishlist: $e');
      return [];
    }
  }

  static Future<void> addToWishlist(String productId) async {
    final user = client.auth.currentUser;
    if (user == null) return;
    await client.from('wishlists').insert({
      'user_id': user.id,
      'product_id': productId,
    });
  }

  static Future<void> removeFromWishlist(String productId) async {
    final user = client.auth.currentUser;
    if (user == null) return;
    await client.from('wishlists').delete().eq('user_id', user.id).eq('product_id', productId);
  }

  // --- Cart ---
  static Future<List<CartItemModel>> getCart() async {
    final user = client.auth.currentUser;
    if (user == null) return [];
    
    try {
      final response = await client
          .from('carts')
          .select('*, products(*)')
          .eq('user_id', user.id);
      
      return (response as List).map((json) {
        final productData = json['products'];
        if (productData == null) return null;
        
        final product = productData is List 
            ? (productData.isNotEmpty ? ProductModel.fromJson(productData[0]) : null)
            : ProductModel.fromJson(productData);
            
        if (product == null) return null;

        return CartItemModel(
          id: json['id'],
          product: product,
          quantity: json['quantity'],
        );
      }).whereType<CartItemModel>().toList();
    } catch (e) {
      print('Error fetching cart: $e');
      return [];
    }
  }

  static Future<void> addToCart(String productId, int quantity) async {
    final user = client.auth.currentUser;
    if (user == null) return;

    await client.from('carts').upsert({
      'user_id': user.id,
      'product_id': productId,
      'quantity': quantity,
    }, onConflict: 'user_id,product_id');
  }

  static Future<void> updateCartQuantity(String cartItemId, int quantity) async {
    await client.from('carts').update({'quantity': quantity}).eq('id', cartItemId);
  }

  static Future<void> removeFromCart(String cartItemId) async {
    await client.from('carts').delete().eq('id', cartItemId);
  }

  static Future<void> clearCart() async {
    final user = client.auth.currentUser;
    if (user == null) return;
    await client.from('carts').delete().eq('user_id', user.id);
  }

  // --- Reviews ---
  static Future<List<ReviewModel>> getProductReviews(String productId) async {
    final response = await client
        .from('reviews')
        .select('*, profiles(first_name, last_name, avatar_url)')
        .eq('product_id', productId)
        .order('created_at', ascending: false);
    
    return (response as List).map((json) => ReviewModel.fromJson(json)).toList();
  }

  static Future<void> addReview(String productId, int rating, String comment) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    await client.from('reviews').upsert({
      'product_id': productId,
      'user_id': user.id,
      'rating': rating,
      'comment': comment,
    }, onConflict: 'user_id,product_id');
  }

  // --- Banners ---
  static Future<List<BannerModel>> getBanners() async {
    final response = await client
        .from('banners')
        .select('*')
        .eq('active', true)
        .order('created_at', ascending: false);
    return (response as List).map((json) => BannerModel.fromJson(json)).toList();
  }

  // --- Search History ---
  static Future<List<String>> getSearchHistory() async {
    final user = client.auth.currentUser;
    if (user == null) return [];
    
    final response = await client
        .from('search_history')
        .select('query')
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(5);
    
    return (response as List).map((json) => json['query'] as String).toList();
  }

  static Future<void> saveSearchQuery(String query) async {
    final user = client.auth.currentUser;
    if (user == null) return;
    if (query.trim().isEmpty) return;

    // Delete existing same query to move it to top
    await client.from('search_history').delete().eq('user_id', user.id).eq('query', query);
    
    await client.from('search_history').insert({
      'user_id': user.id,
      'query': query,
    });
  }

  static Future<void> clearSearchHistory() async {
    final user = client.auth.currentUser;
    if (user == null) return;
    await client.from('search_history').delete().eq('user_id', user.id);
  }

  // --- Recently Viewed ---
  static Future<List<ProductModel>> getRecentlyViewed() async {
    final user = client.auth.currentUser;
    if (user == null) return [];

    final response = await client
        .from('recently_viewed')
        .select('products(*)')
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(10);

    return (response as List)
        .where((json) => json['products'] != null)
        .map((json) => ProductModel.fromJson(json['products']))
        .toList();
  }

  static Future<void> saveRecentlyViewed(String productId) async {
    final user = client.auth.currentUser;
    if (user == null) return;

    // Delete existing same product to move it to top
    await client.from('recently_viewed').delete().eq('user_id', user.id).eq('product_id', productId);

    await client.from('recently_viewed').insert({
      'user_id': user.id,
      'product_id': productId,
    });
  }

  static Future<void> clearRecentlyViewed() async {
    final user = client.auth.currentUser;
    if (user == null) return;
    await client.from('recently_viewed').delete().eq('user_id', user.id);
  }

  // --- Related Products ---
  static Future<List<ProductModel>> getRelatedProducts({
    required String productId,
    String? subcategoryId,
    String? categoryId,
    int limit = 6,
  }) async {
    var query = client.from('products').select('*').neq('id', productId);

    if (subcategoryId != null) {
      query = query.eq('sub_category_id', subcategoryId);
    } else if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }

    // Shuffle and limit on client side or use a random factor if possible
    // For now, we'll just take the top ones and limit
    final response = await query.limit(limit);

    return (response as List).map((json) => ProductModel.fromJson(json)).toList();
  }

  static Future<List<ProductModel>> getCollaborativeRecommendations({
    required String productId,
    int limit = 6,
  }) async {
    try {
      final response = await client.rpc(
        'get_collaborative_recommendations',
        params: {
          'current_product_id': productId,
          'max_limit': limit,
        },
      );
      return (response as List).map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      print('Collaborative Filtering Error: $e');
      return [];
    }
  }

  // --- Settings ---
  static Future<Map<String, String>> getSettings() async {
    final response = await client.from('settings').select('*');
    final data = response as List;
    return Map.fromEntries(
      data.map((item) => MapEntry(item['key'] as String, item['value'] as String? ?? ''))
    );
  }

  // --- Delivery Estimates ---
  static Future<Map<String, dynamic>?> checkDeliveryEstimate(String pincode) async {
    try {
      final response = await client.rpc(
        'check_delivery_estimate',
        params: {'p_pincode': pincode},
      );
      final data = response as List;
      if (data.isEmpty) return null;
      return data.first as Map<String, dynamic>;
    } catch (e) {
      print('Delivery Estimate Error: $e');
      return null;
    }
  }
  // --- FAQs & Support ---
  static Future<List<Map<String, dynamic>>> getFaqs() async {
    final response = await client
        .from('faqs')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<String?> createSupportTicket(String message, {String? subject}) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await client.from('support_tickets').insert({
      'user_id': userId,
      'subject': subject,
      'message': message, // Initial message
      'status': 'Open',
    }).select('id').single();

    final ticketId = response['id'] as String;

    // Also add to messages table for chat history
    await sendSupportMessage(ticketId, message);
    
    return ticketId;
  }

  static Future<List<Map<String, dynamic>>> getUserSupportTickets() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await client
        .from('support_tickets')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>> getSupportMessages(String ticketId) async {
    final response = await client
        .from('support_messages')
        .select()
        .eq('ticket_id', ticketId)
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> sendSupportMessage(String ticketId, String message, {bool isAdmin = false}) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    await client.from('support_messages').insert({
      'ticket_id': ticketId,
      'sender_id': userId,
      'message': message,
      'is_admin': isAdmin,
    });
    
    // Update ticket's updated_at
    await client.from('support_tickets').update({
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', ticketId);
  }

  // --- Coupons ---
  static Future<CouponModel?> validateCoupon(String code) async {
    try {
      final response = await client
          .from('coupons')
          .select('*')
          .eq('code', code)
          .eq('active', true)
          .gte('expiry', DateTime.now().toIso8601String())
          .maybeSingle();

      if (response == null) return null;
      return CouponModel.fromJson(response);
    } catch (e) {
      print('Error validating coupon: $e');
      return null;
    }
  }
}
