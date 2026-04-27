import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

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
    var query = client.from('products').select('*, categories!inner(*)');
    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }
    if (categoryName != null) {
      query = query.eq('categories.title', categoryName);
    }
    final response = await query;
    return (response as List).map((json) => ProductModel.fromJson(json)).toList();
  }

  static Future<List<ProductModel>> getTrendingProducts() async {
    final response = await client
        .from('products')
        .select('*')
        .limit(10)
        .order('created_at', ascending: false);
    return (response as List).map((json) => ProductModel.fromJson(json)).toList();
  }

  // --- User Profile ---
  static Future<Map<String, dynamic>?> getProfile() async {
    final user = client.auth.currentUser;
    if (user == null) return null;
    return await client.from('profiles').select('*').eq('id', user.id).single();
  }

  // --- Addresses ---
  static Future<List<Map<String, dynamic>>> getAddresses() async {
    final user = client.auth.currentUser;
    if (user == null) return [];
    return await client.from('addresses').select('*').eq('user_id', user.id);
  }

  // --- Orders ---
  static Future<List<Map<String, dynamic>>> getOrders() async {
    final user = client.auth.currentUser;
    if (user == null) return [];
    return await client.from('orders').select('*, order_items(*, products(*))').eq('user_id', user.id);
  }

  // --- Wishlist ---
  static Future<List<ProductModel>> getWishlist() async {
    final user = client.auth.currentUser;
    if (user == null) return [];
    
    final response = await client
        .from('wishlists')
        .select('products(*)')
        .eq('user_id', user.id);
    
    return (response as List).map((json) => ProductModel.fromJson(json['products'])).toList();
  }
}
