import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class FilterModal extends StatefulWidget {
  const FilterModal({super.key});

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  bool isFilterTab = true;
  String? selectedSort;
  bool availableInStock = false;

  final List<String> sortOptions = [
    "Price [Low to High]",
    "Price [High to Low]",
    "New",
    "Highest Rated",
    "A-Z",
    "Z-A",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                Text(
                  isFilterTab ? "Filter" : "Sort",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedSort = null;
                      availableInStock = false;
                    });
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
                        borderRadius: BorderRadius.circular(defaultBorderRadious),
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
                        borderRadius: BorderRadius.circular(defaultBorderRadious),
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
            child: isFilterTab ? _buildFilterContent() : _buildSortContent(),
          ),
          // Footer
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Done"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterContent() {
    return ListView(
      children: [
        ListTile(
          title: const Text("Category"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        const Divider(height: 1),
        ListTile(
          title: const Text("Brand"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        const Divider(height: 1),
        ListTile(
          title: const Text("Price"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        const Divider(height: 1),
        CheckboxListTile(
          title: const Text("Available in stock"),
          value: availableInStock,
          onChanged: (val) {
            setState(() {
              availableInStock = val ?? false;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        ),
      ],
    );
  }

  Widget _buildSortContent() {
    return ListView.separated(
      itemCount: sortOptions.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final option = sortOptions[index];
        return CheckboxListTile(
          title: Text(option),
          value: selectedSort == option,
          onChanged: (val) {
            setState(() {
              if (val == true) {
                selectedSort = option;
              } else {
                selectedSort = null;
              }
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        );
      },
    );
  }
}
