import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop/constants.dart';
import 'package:shop/providers/providers.dart';

class FilterModal extends ConsumerStatefulWidget {
  const FilterModal({super.key});

  @override
  ConsumerState<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends ConsumerState<FilterModal> {
  bool isFilterTab = true;

  final List<String> sortOptions = [
    "Price [Low to High]",
    "Price [High to Low]",
    "Highest Rated",
    "A-Z",
    "Z-A",
  ];

  @override
  Widget build(BuildContext context) {
    final searchParams = ref.watch(searchParamsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.only(top: defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 48), // Spacer to balance Clear All
                Text(
                  isFilterTab ? "Filter" : "Sort",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () {
                    ref.read(searchParamsProvider.notifier).clearAll();
                  },
                  child: const Text("Clear All"),
                ),
              ],
            ),
          ),
          const SizedBox(height: defaultPadding),
          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isFilterTab = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isFilterTab ? primaryColor : Colors.transparent,
                        border: Border.all(
                            color: isFilterTab
                                ? primaryColor
                                : Theme.of(context).dividerColor),
                        borderRadius: BorderRadius.circular(defaultBorderRadius),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Filter",
                        style: TextStyle(
                          color: isFilterTab
                              ? Colors.white
                              : Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: defaultPadding),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isFilterTab = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !isFilterTab ? primaryColor : Colors.transparent,
                        border: Border.all(
                            color: !isFilterTab
                                ? primaryColor
                                : Theme.of(context).dividerColor),
                        borderRadius: BorderRadius.circular(defaultBorderRadius),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Sort",
                        style: TextStyle(
                          color: !isFilterTab
                              ? Colors.white
                              : Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: defaultPadding),
          const Divider(height: 1),
          // Content
          Expanded(
            child: isFilterTab 
              ? _buildFilterContent(searchParams, categoriesAsync) 
              : _buildSortContent(searchParams),
          ),
          // Footer
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Apply"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterContent(SearchState params, AsyncValue categoriesAsync) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Text("Category", style: Theme.of(context).textTheme.titleSmall),
        ),
        categoriesAsync.when(
          data: (categories) => Wrap(
            spacing: 8,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text("All"),
                      selected: params.category == null,
                      onSelected: (_) => ref.read(searchParamsProvider.notifier).setCategory(null),
                    ),
                    ...categories.map((cat) => FilterChip(
                      label: Text(cat.title),
                      selected: params.category == cat.title,
                      onSelected: (_) => ref.read(searchParamsProvider.notifier).setCategory(cat.title),
                    )),
                  ],
                ),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => const Text("Error loading categories"),
        ),
        const Divider(height: 32),
        CheckboxListTile(
          title: const Text("Available in stock"),
          value: params.availableInStock,
          onChanged: (val) {
            ref.read(searchParamsProvider.notifier).setInStock(val ?? false);
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        ),
      ],
    );
  }

  Widget _buildSortContent(SearchState params) {
    return ListView.separated(
      itemCount: sortOptions.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final option = sortOptions[index];
        return RadioGroup<String>(
          groupValue: params.sortOption,
          onChanged: (val) {
            ref.read(searchParamsProvider.notifier).setSortOption(val);
          },
          child: RadioListTile<String>(
            title: Text(option),
            value: option,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          ),
        );
      },
    );
  }
}
