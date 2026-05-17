import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';
import '../models/review_model.dart';
import '../models/coupon_model.dart';
import '../services/supabase_service.dart';
import '../services/logistics_service.dart';

// Reviews Provider
final reviewsProvider = FutureProvider.family<List<ReviewModel>, String>((ref, productId) async {
  return SupabaseService.getProductReviews(productId);
});

enum ReviewSort { mostRecent, highestRated, lowestRated }

class ReviewSortNotifier extends Notifier<ReviewSort> {
  @override
  ReviewSort build() => ReviewSort.mostRecent;
  void setSort(ReviewSort sort) => state = sort;
}

final reviewSortProvider = NotifierProvider<ReviewSortNotifier, ReviewSort>(() {
  return ReviewSortNotifier();
});

// Banners Provider
final bannersProvider = FutureProvider<List<BannerModel>>((ref) async {
  return SupabaseService.getBanners();
});

// Categories Provider
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  return SupabaseService.getCategories();
});

// Products Provider
final productsProvider = FutureProvider<List<ProductModel>>((ref) async {
  return SupabaseService.getProducts();
});

// Trending Products Provider
final trendingProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  return SupabaseService.getTrendingProducts();
});

// Cart State Management
class CartNotifier extends AsyncNotifier<List<CartItemModel>> {
  List<CartItemModel> _guestCart = [];

  @override
  Future<List<CartItemModel>> build() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) return _guestCart;
    return SupabaseService.getCart();
  }

  Future<void> addToCart(String productId, int quantity) async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) {
      // Find product first to add to guest cart
      final products = await ref.read(productsProvider.future);
      final product = products.firstWhere((p) => p.id == productId);
      
      final index = _guestCart.indexWhere((item) => item.product.id == productId);
      if (index >= 0) {
        _guestCart[index] = CartItemModel(
          id: _guestCart[index].id,
          product: product,
          quantity: _guestCart[index].quantity + quantity,
        );
      } else {
        _guestCart.add(CartItemModel(
          id: DateTime.now().toString(),
          product: product,
          quantity: quantity,
        ));
      }
      state = AsyncData(List.from(_guestCart));
    } else {
      await SupabaseService.addToCart(productId, quantity);
      ref.invalidateSelf();
    }
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) {
      final index = _guestCart.indexWhere((item) => item.id == cartItemId);
      if (index >= 0) {
        _guestCart[index] = CartItemModel(
          id: cartItemId,
          product: _guestCart[index].product,
          quantity: quantity,
        );
      }
      state = AsyncData(List.from(_guestCart));
    } else {
      await SupabaseService.updateCartQuantity(cartItemId, quantity);
      ref.invalidateSelf();
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) {
      _guestCart.removeWhere((item) => item.id == cartItemId);
      state = AsyncData(List.from(_guestCart));
    } else {
      await SupabaseService.removeFromCart(cartItemId);
      ref.invalidateSelf();
    }
  }

  Future<void> clearCart() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) {
      _guestCart = [];
      state = AsyncData(_guestCart);
    } else {
      await SupabaseService.clearCart();
      ref.invalidateSelf();
    }
  }
}

final cartProvider = AsyncNotifierProvider<CartNotifier, List<CartItemModel>>(
  () => CartNotifier(),
);

// Wishlist State Management
class WishlistNotifier extends AsyncNotifier<List<ProductModel>> {
  List<ProductModel> _guestWishlist = [];

  @override
  Future<List<ProductModel>> build() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) return _guestWishlist;
    return SupabaseService.getWishlist();
  }

  Future<void> toggleWishlist(String productId, {ProductModel? product}) async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) {
      final currentList = state.value ?? _guestWishlist;
      final index = currentList.indexWhere((p) => p.id == productId);
      
      if (index >= 0) {
        _guestWishlist = List.from(currentList)..removeAt(index);
      } else {
        if (product != null) {
          _guestWishlist = List.from(currentList)..add(product);
        } else {
          try {
            final products = await ref.read(productsProvider.future);
            final foundProduct = products.firstWhere((p) => p.id == productId);
            _guestWishlist = List.from(currentList)..add(foundProduct);
          } catch (e) {
            debugPrint('Error adding to guest wishlist: $e');
            // If still not found, we can't add it without the model
            return;
          }
        }
      }
      state = AsyncData(List.from(_guestWishlist));
    } else {
      try {
        final wishlist = await future;
        final isBookmarked = wishlist.any((p) => p.id == productId);

        if (isBookmarked) {
          await SupabaseService.removeFromWishlist(productId);
        } else {
          await SupabaseService.addToWishlist(productId);
        }
        ref.invalidateSelf();
      } catch (e) {
        state = AsyncError(e, StackTrace.current);
      }
    }
  }
}

final wishlistProvider = AsyncNotifierProvider<WishlistNotifier, List<ProductModel>>(
  () => WishlistNotifier(),
);

// Search & Filter State
class SearchState {
  final String query;
  final String? category;
  final String? sortOption;
  final bool availableInStock;

  SearchState({
    this.query = "",
    this.category,
    this.sortOption,
    this.availableInStock = false,
  });

  SearchState copyWith({
    String? query,
    String? Function()? category,
    String? Function()? sortOption,
    bool? availableInStock,
  }) {
    return SearchState(
      query: query ?? this.query,
      category: category != null ? category() : this.category,
      sortOption: sortOption != null ? sortOption() : this.sortOption,
      availableInStock: availableInStock ?? this.availableInStock,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  @override
  SearchState build() => SearchState();

  void setQuery(String query) => state = state.copyWith(query: query);
  void setCategory(String? category) => state = state.copyWith(category: () => category);
  void setSortOption(String? sortOption) => state = state.copyWith(sortOption: () => sortOption);
  void setInStock(bool val) => state = state.copyWith(availableInStock: val);
  void clearAll() => state = SearchState();
}

final searchParamsProvider = NotifierProvider<SearchNotifier, SearchState>(() {
  return SearchNotifier();
});

// Search History State Management
class SearchHistoryNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    return SupabaseService.getSearchHistory();
  }

  Future<void> addQuery(String query) async {
    await SupabaseService.saveSearchQuery(query);
    ref.invalidateSelf();
  }

  Future<void> clearHistory() async {
    await SupabaseService.clearSearchHistory();
    ref.invalidateSelf();
  }
}

final searchHistoryProvider = AsyncNotifierProvider<SearchHistoryNotifier, List<String>>(
  () => SearchHistoryNotifier(),
);

// Recently Viewed State Management
class RecentlyViewedNotifier extends AsyncNotifier<List<ProductModel>> {
  @override
  Future<List<ProductModel>> build() async {
    return SupabaseService.getRecentlyViewed();
  }

  Future<void> addProduct(String productId) async {
    await SupabaseService.saveRecentlyViewed(productId);
    ref.invalidateSelf();
  }

  Future<void> clearHistory() async {
    await SupabaseService.clearRecentlyViewed();
    ref.invalidateSelf();
  }
}

final recentlyViewedProvider = AsyncNotifierProvider<RecentlyViewedNotifier, List<ProductModel>>(
  () => RecentlyViewedNotifier(),
);

final relatedProductsProvider = FutureProvider.family<List<ProductModel>, ProductModel>((ref, product) async {
  return SupabaseService.getRelatedProducts(
    productId: product.id,
    subcategoryId: product.subCategoryId,
    categoryId: product.category,
  );
});

final collaborativeRecommendationsProvider = FutureProvider.family<List<ProductModel>, ProductModel>((ref, product) async {
  return SupabaseService.getCollaborativeRecommendations(
    productId: product.id,
  );
});

final filteredProductsProvider = Provider<AsyncValue<List<ProductModel>>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  final searchParams = ref.watch(searchParamsProvider);

  return productsAsync.whenData((products) {
    var filtered = products.where((product) {
      // Query filter
      final matchesQuery = product.title.toLowerCase().contains(searchParams.query.toLowerCase()) ||
          product.brandName.toLowerCase().contains(searchParams.query.toLowerCase());
      
      // Category filter
      final matchesCategory = searchParams.category == null || 
          (product.categoryTitle?.toLowerCase() == searchParams.category!.toLowerCase()) ||
          (product.subCategoryTitle?.toLowerCase() == searchParams.category!.toLowerCase());

      // Stock filter (assuming stock info is in model, if not skip)
      // For now, assume always matches if stock info missing or simple check
      
      return matchesQuery && matchesCategory;
    }).toList();

    // Sorting
    if (searchParams.sortOption != null) {
      switch (searchParams.sortOption) {
        case "Price [Low to High]":
          filtered.sort((a, b) => (a.priceAfterDiscount ?? a.price).compareTo(b.priceAfterDiscount ?? b.price));
          break;
        case "Price [High to Low]":
          filtered.sort((a, b) => (b.priceAfterDiscount ?? b.price).compareTo(a.priceAfterDiscount ?? a.price));
          break;
        case "A-Z":
          filtered.sort((a, b) => a.title.compareTo(b.title));
          break;
        case "Z-A":
          filtered.sort((a, b) => b.title.compareTo(a.title));
          break;
        case "Highest Rated":
          filtered.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
          break;
      }
    }

    return filtered;
  });
});

// Navigation State Management
class NavigationNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) => state = index;
}

final navigationProvider = NotifierProvider<NavigationNotifier, int>(() {
  return NavigationNotifier();
});
final userIdProvider = Provider<String?>((ref) {
  return SupabaseService.client.auth.currentUser?.id;
});

// Settings Provider
final settingsProvider = FutureProvider<Map<String, String>>((ref) async {
  return SupabaseService.getSettings();
});

// Pincode Estimate Provider
final pincodeEstimateProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, pincode) async {
  if (pincode.length < 6) return null;
  // Use Shiprocket for live estimation
  final estimate = await LogisticsService().getEstimatedDelivery(pincode);
  if (estimate['status'] == 'success') {
    return {
      'min_days': estimate['days'] is int ? estimate['days'] : 3,
      'max_days': estimate['days'] is int ? (estimate['days'] + 2) : 5,
      'description': "Delivered via ${estimate['courier']}",
      'is_live': true,
      'etd': estimate['etd'],
    };
  }
  
  // Fallback to local DB estimate if Shiprocket fails or not serviceable
  return SupabaseService.checkDeliveryEstimate(pincode);
});

// Coupon State Management
class CouponNotifier extends Notifier<CouponModel?> {
  @override
  CouponModel? build() => null;

  Future<String?> applyCoupon(String code) async {
    final coupon = await SupabaseService.validateCoupon(code);
    if (coupon == null) {
      return "Invalid or expired coupon code";
    }
    state = coupon;
    return null; // Success
  }

  void removeCoupon() {
    state = null;
  }
}

final couponProvider = NotifierProvider<CouponNotifier, CouponModel?>(() {
  return CouponNotifier();
});

extension SettingsExtension on Map<String, String> {
  double getDouble(String key, double defaultValue) {
    final value = this[key];
    if (value == null) return defaultValue;
    return double.tryParse(value) ?? defaultValue;
  }
}

class ShippingSettings {
  final double fee;
  final double threshold;
  ShippingSettings({required this.fee, required this.threshold});
}

final shippingSettingsProvider = Provider<ShippingSettings>((ref) {
  final settings = ref.watch(settingsProvider).value ?? {};
  return ShippingSettings(
    fee: settings.getDouble('shipping_fee', 50),
    threshold: settings.getDouble('shipping_threshold', 999),
  );
});
