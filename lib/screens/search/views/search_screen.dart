import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/route/route_constants.dart';
import 'components/search_form.dart';
import 'components/filter_modal.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final List<String> recentSearches = [
    "Fire Bucket",
    "Uniforms",
    "Density Kit",
    "Cam Lock",
    "Spill Kit",
  ];

  String _searchQuery = "";

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SizedBox(
        height: 600,
        child: FilterModal(),
      ),
    );
  }

  void _handleSearch(String? query) {
    if (query != null && query.trim().isNotEmpty) {
      setState(() {
        _searchQuery = query;
        if (!recentSearches.contains(query)) {
          recentSearches.insert(0, query);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = demoProducts
        .where((product) =>
            product.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            product.brandName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (product.category?.toLowerCase() ?? "").contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding,
                vertical: defaultPadding / 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_searchQuery.isEmpty)
                    const BackButton()
                  else
                    const Text(
                      "PetroWorld",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _searchQuery = "";
                        });
                      },
                    ),
                ],
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding,
                vertical: defaultPadding / 2,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SearchForm(
                      autofocus: true,
                      onTabFilter: _showFilterModal,
                      onFieldSubmitted: _handleSearch,
                    ),
                  ),
                ],
              ),
            ),
            if (_searchQuery.isEmpty) ...[
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
                    TextButton(
                      onPressed: () {
                        setState(() {
                          recentSearches.clear();
                        });
                      },
                      child: const Text("See All"),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Recent Searches List
              Expanded(
                child: ListView.separated(
                  itemCount: recentSearches.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.access_time_outlined, color: blackColor40),
                      title: Text(recentSearches[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 16, color: blackColor40),
                        onPressed: () {
                          setState(() {
                            recentSearches.removeAt(index);
                          });
                        },
                      ),
                      onTap: () {
                        _handleSearch(recentSearches[index]);
                      },
                    );
                  },
                ),
              ),
            ] else ...[
              // Search Results Header
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
                      "(${filteredProducts.length} items)",
                      style: const TextStyle(color: blackColor40),
                    ),
                  ],
                ),
              ),
              // Search Results Grid
              Expanded(
                child: filteredProducts.isEmpty
                    ? const Center(child: Text("No products found"))
                    : GridView.builder(
                        padding: const EdgeInsets.all(defaultPadding),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.6,
                          mainAxisSpacing: defaultPadding,
                          crossAxisSpacing: defaultPadding,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          return ProductCard(
                            image: filteredProducts[index].image,
                            brandName: filteredProducts[index].brandName,
                            title: filteredProducts[index].title,
                            price: filteredProducts[index].price,
                            priceAfterDiscount:
                                filteredProducts[index].priceAfterDiscount,
                            discountPercent:
                                filteredProducts[index].discountPercent,
                            press: () {
                              Navigator.pushNamed(context, productDetailsScreenRoute,
                                  arguments: filteredProducts[index]);
                            },
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
