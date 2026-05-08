import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop/models/banner_model.dart';
import 'package:shop/models/category_model.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/models/cart_item_model.dart';
import 'package:shop/models/review_model.dart';
import 'package:shop/services/supabase_service.dart';
import 'package:shop/services/logistics_service.dart';

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
  @override
  Future<List<CartItemModel>> build() async {
    return SupabaseService.getCart();
  }

  Future<void> addToCart(String productId, int quantity) async {
    await SupabaseService.addToCart(productId, quantity);
    ref.invalidateSelf(); // refresh the cart
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    await SupabaseService.updateCartQuantity(cartItemId, quantity);
    ref.invalidateSelf();
  }

  Future<void> removeFromCart(String cartItemId) async {
    await SupabaseService.removeFromCart(cartItemId);
    ref.invalidateSelf();
  }

  Future<void> clearCart() async {
    await SupabaseService.clearCart();
    ref.invalidateSelf();
  }
}

final cartProvider = AsyncNotifierProvider<CartNotifier, List<CartItemModel>>(
  () => CartNotifier(),
);

// Wishlist State Management
class WishlistNotifier extends AsyncNotifier<List<ProductModel>> {
  @override
  Future<List<ProductModel>> build() async {
    return SupabaseService.getWishlist();
  }

  Future<void> toggleWishlist(String productId) async {
    final wishlist = await future;
    final isBookmarked = wishlist.any((p) => p.id == productId);

    if (isBookmarked) {
      await SupabaseService.removeFromWishlist(productId);
    } else {
      await SupabaseService.addToWishlist(productId);
    }
    ref.invalidateSelf();
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
