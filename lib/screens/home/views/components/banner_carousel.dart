import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop/components/dot_indicators.dart';
import 'package:shop/components/shimmer_wrapper.dart';
import 'package:shop/components/network_image_with_loader.dart';
import '../../../../constants.dart';
import '../../../../providers/providers.dart';

class BannerCarousel extends ConsumerStatefulWidget {
  const BannerCarousel({super.key});

  @override
  ConsumerState<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends ConsumerState<BannerCarousel> {
  int _selectedIndex = 0;
  late PageController _pageController;
  Timer? _timer;

  @override
  void initState() {
    _pageController = PageController(initialPage: 5000);
    super.initState();
  }

  void _startAutoScroll(int bannersLength) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (!_pageController.hasClients || bannersLength <= 1) return;
      
      int nextPage = _pageController.page!.toInt() + 1;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bannersAsyncValue = ref.watch(bannersProvider);

    return AspectRatio(
      aspectRatio: 1.87,
      child: bannersAsyncValue.when(
        loading: () => const BannerCarouselSkeleton(),
        error: (error, stack) => const Center(child: Text("Failed to load banners")),
        data: (banners) {
          if (banners.isEmpty) return const SizedBox.shrink();

          // Initialize scrolling only once
          if (_timer == null && banners.length > 1) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_pageController.hasClients) {
                int middlePage = (5000 ~/ banners.length) * banners.length;
                _pageController.jumpToPage(middlePage);
                _startAutoScroll(banners.length);
              }
            });
          }

          return Stack(
            alignment: Alignment.bottomRight,
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: 10000, 
                onPageChanged: (int index) {
                  setState(() {
                    _selectedIndex = index % banners.length;
                  });
                },
                itemBuilder: (context, index) {
                  final banner = banners[index % banners.length];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                    child: GestureDetector(
                      onTap: () {
                        // Action on tap
                      },
                      child: NetworkImageWithLoader(
                        banner.imageUrl,
                        radius: defaultBorderRadius,
                      ),
                    ),
                  );
                },
              ),
              if (banners.length > 1)
                FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding * 1.5),
                    child: SizedBox(
                      height: 16,
                      child: Row(
                        children: List.generate(
                          banners.length,
                          (index) {
                            return Padding(
                              padding: const EdgeInsets.only(left: defaultPadding / 4),
                              child: DotIndicator(
                                isActive: index == _selectedIndex,
                                activeColor: Colors.white,
                                inActiveColor: Colors.white54,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                )
            ],
          );
        },
      ),
    );
  }
}

class BannerCarouselSkeleton extends StatelessWidget {
  const BannerCarouselSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: defaultPadding),
      child: ShimmerWrapper(
        child: SkeletonBox(
          width: double.infinity,
          height: double.infinity,
          borderRadius: defaultBorderRadius,
        ),
      ),
    );
  }
}
