import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop/constants.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/route/route_constants.dart';
import 'components/search_form.dart';
import 'components/filter_modal.dart';
import 'package:shop/providers/providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: ref.read(searchParamsProvider).query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchParams = ref.watch(searchParamsProvider);
    final filteredProductsAsync = ref.watch(filteredProductsProvider);
    final wishlistAsyncValue = ref.watch(wishlistProvider);
    final searchHistoryAsync = ref.watch(searchHistoryProvider);

    // Sync controller if state changes externally (e.g. from recent search tap)
    if (_searchController.text != searchParams.query) {
      _searchController.text = searchParams.query;
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding,
                vertical: defaultPadding / 2,
              ),
              child: SearchForm(
                controller: _searchController,
                focusNode: FocusNode(),
                autofocus: searchParams.query.isEmpty && searchParams.category == null,
                onTabFilter: _showFilterModal,
                onChanged: (query) {
                  ref.read(searchParamsProvider.notifier).setQuery(query ?? "");
                },
                onFieldSubmitted: (query) {
                  if (query != null && query.isNotEmpty) {
                    ref.read(searchHistoryProvider.notifier).addQuery(query);
                  }
                },
              ),
            ),
            // Active Filters Row
            if (searchParams.category != null || searchParams.sortOption != null)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Row(
                  children: [
                    if (searchParams.category != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InputChip(
                          label: Text(searchParams.category!),
                          onDeleted: () => ref.read(searchParamsProvider.notifier).setCategory(null),
                          backgroundColor: primaryColor.withValues(alpha: 0.1),
                          deleteIconColor: Colors.black54,
                        ),
                      ),
                    if (searchParams.sortOption != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InputChip(
                          label: Text(searchParams.sortOption!),
                          onDeleted: () => ref.read(searchParamsProvider.notifier).setSortOption(null),
                          backgroundColor: primaryColor.withValues(alpha: 0.1),
                          deleteIconColor: Colors.black54,
                        ),
                      ),
                  ],
                ),
              ),

            if (searchParams.query.isEmpty && searchParams.category == null) ...[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Recent Searches Header
                      Padding(
                        padding: const EdgeInsets.all(defaultPadding),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Recent Searches",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      // Recent Searches List
                      searchHistoryAsync.when(
                        data: (history) => ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: history.length > 5 ? 5 : history.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: const Icon(Icons.access_time_outlined, color: blackColor40),
                              title: Text(history[index]),
                              trailing: const Icon(Icons.north_west, size: 16, color: blackColor40),
                              onTap: () {
                                ref.read(searchParamsProvider.notifier).setQuery(history[index]);
                              },
                            );
                          },
                        ),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, s) => const Center(child: Text("Error loading history")),
                      ),
                      const Divider(height: 1),
                      const SizedBox(height: defaultPadding),

                      // Recently Viewed Section
                      Consumer(
                        builder: (context, ref, child) {
                          final recentlyViewedAsync = ref.watch(recentlyViewedProvider);
                          return recentlyViewedAsync.when(
                            data: (products) {
                              if (products.isEmpty) return const SizedBox.shrink();
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Recently Viewed",
                                          style: Theme.of(context).textTheme.titleSmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 240,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                                      itemCount: products.length,
                                      itemBuilder: (context, index) {
                                        final product = products[index];
                                        final isBookmarked = wishlistAsyncValue.maybeWhen(
                                          data: (wishlist) => wishlist.any((p) => p.id == product.id),
                                          orElse: () => false,
                                        );

                                        return Padding(
                                          padding: const EdgeInsets.only(right: defaultPadding),
                                          child: SizedBox(
                                            width: 140,
                                            child: ProductCard(
                                              productId: product.id,
                                              image: product.image,
                                              brandName: product.brandName,
                                              title: product.title,
                                              price: product.price,
                                              priceAfterDiscount: product.priceAfterDiscount,
                                              discountPercent: product.discountPercent,
                                              discountType: product.discountType,
                                              discountValue: product.discountValue,
                                              rating: product.rating,
                                              reviewCount: product.reviewCount,
                                              isBookmarked: isBookmarked,
                                              onBookmarkTap: () {
                                                ref.read(wishlistProvider.notifier).toggleWishlist(product.id, product: product);
                                              },
                                              press: () {
                                                Navigator.pushNamed(context, productDetailsScreenRoute,
                                                    arguments: product);
                                              },
                                              product: product,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: defaultPadding),
                                ],
                              );
                            },
                            loading: () => const SizedBox.shrink(),
                            error: (e, s) => const SizedBox.shrink(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                child: filteredProductsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                  data: (products) {
                    if (products.isEmpty) {
                      return const Center(child: Text("No products found"));
                    }

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: defaultPadding,
                            vertical: defaultPadding / 2,
                          ),
                          child: Row(
                            children: [
                              Text(
                                "Search result ",
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              Text(
                                "(${products.length} items)",
                                style: const TextStyle(color: blackColor40),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.all(defaultPadding),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.55,
                              mainAxisSpacing: defaultPadding,
                              crossAxisSpacing: defaultPadding,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              final isBookmarked = wishlistAsyncValue.maybeWhen(
                                data: (wishlist) => wishlist.any((p) => p.id == product.id),
                                orElse: () => false,
                              );

                              return ProductCard(
                                productId: product.id,
                                image: product.image,
                                brandName: product.brandName,
                                title: product.title,
                                price: product.price,
                                priceAfterDiscount: product.priceAfterDiscount,
                                discountPercent: product.discountPercent,
                                discountType: product.discountType,
                                discountValue: product.discountValue,
                                rating: product.rating,
                                reviewCount: product.reviewCount,
                                isBookmarked: isBookmarked,
                                onBookmarkTap: () {
                                  ref.read(wishlistProvider.notifier).toggleWishlist(product.id, product: product);
                                },
                                press: () {
                                  Navigator.pushNamed(context, productDetailsScreenRoute,
                                      arguments: product);
                                },
                                product: product,
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
