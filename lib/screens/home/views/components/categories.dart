import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petro_world/components/shimmer_wrapper.dart';
import '../../../../constants.dart';

import 'package:petro_world/models/category_model.dart';
import 'package:petro_world/providers/providers.dart';

class Categories extends ConsumerWidget {
  const Categories({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsyncValue = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(homeSelectedCategoryProvider);

    return categoriesAsyncValue.when(
      loading: () => const CategoryListSkeleton(),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (data) {
        final categories = [
          CategoryModel(id: 'all', title: "All Categories"),
          ...data,
        ];

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...List.generate(
                categories.length,
                (index) => Padding(
                  padding: EdgeInsets.only(
                      left: index == 0 ? defaultPadding : defaultPadding / 2,
                      right:
                          index == categories.length - 1 ? defaultPadding : 0),
                  child: CategoryBtn(
                    category: categories[index].title,
                    svgSrc: categories[index].svgSrc,
                    isActive: categories[index].title == "All Categories"
                        ? selectedCategory == null
                        : selectedCategory == categories[index].title,
                    press: () {
                      if (categories[index].title == "All Categories") {
                        ref
                            .read(homeSelectedCategoryProvider.notifier)
                            .setCategory(null);
                      } else {
                        ref
                            .read(homeSelectedCategoryProvider.notifier)
                            .setCategory(categories[index].title);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CategoryListSkeleton extends StatelessWidget {
  const CategoryListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Row(
        children: List.generate(
          5,
          (index) => Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? defaultPadding : defaultPadding / 2,
              right: index == 4 ? defaultPadding : 0,
            ),
            child: const ShimmerWrapper(
              child: SkeletonBox(
                width: 100,
                height: 36,
                borderRadius: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryBtn extends StatelessWidget {
  const CategoryBtn({
    super.key,
    required this.category,
    this.svgSrc,
    required this.isActive,
    required this.press,
  });

  final String category;
  final String? svgSrc;
  final bool isActive;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      borderRadius: const BorderRadius.all(Radius.circular(30)),
      child: AnimatedContainer(
        duration: defaultDuration,
        curve: Curves.easeOutCubic,
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        decoration: BoxDecoration(
          color: isActive ? primaryColor : Colors.transparent,
          border: Border.all(
              color: isActive
                  ? Colors.transparent
                  : Theme.of(context).dividerColor),
          borderRadius: const BorderRadius.all(Radius.circular(30)),
        ),
        child: Row(
          children: [
            if (svgSrc != null)
              SvgPicture.asset(
                svgSrc!,
                height: 20,
                colorFilter: ColorFilter.mode(
                  isActive ? Colors.white : Theme.of(context).iconTheme.color!,
                  BlendMode.srcIn,
                ),
              ),
            if (svgSrc != null) const SizedBox(width: defaultPadding / 2),
            AnimatedDefaultTextStyle(
              duration: defaultDuration,
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyLarge!.color,
              ),
              child: Text(
                category,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
