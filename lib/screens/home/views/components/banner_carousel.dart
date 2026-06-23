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

    return bannersAsyncValue.when(
      loading: () => const AspectRatio(
        aspectRatio: 1.87,
        child: BannerCarouselSkeleton(),
      ),
      error: (error, stack) => const _FallbackPromoBanner(),
      data: (banners) {
        final usableBanners =
            banners.where((banner) => banner.imageUrl.isNotEmpty).toList();
        if (usableBanners.isEmpty) return const _FallbackPromoBanner();

        // Initialize scrolling only once
        if (_timer == null && usableBanners.length > 1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            if (_pageController.hasClients) {
              int middlePage =
                  (5000 ~/ usableBanners.length) * usableBanners.length;
              _pageController.jumpToPage(middlePage);
              _startAutoScroll(usableBanners.length);
            }
          });
        }

        return AspectRatio(
          aspectRatio: 1.87,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: 10000,
                onPageChanged: (int index) {
                  setState(() {
                    _selectedIndex = index % usableBanners.length;
                  });
                },
                itemBuilder: (context, index) {
                  final banner = usableBanners[index % usableBanners.length];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: defaultPadding),
                    child: GestureDetector(
                      onTap: () {},
                      child: NetworkImageWithLoader(
                        banner.imageUrl,
                        radius: defaultBorderRadius,
                      ),
                    ),
                  );
                },
              ),
              if (usableBanners.length > 1)
                FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding * 1.5),
                    child: SizedBox(
                      height: 16,
                      child: Row(
                        children: List.generate(
                          usableBanners.length,
                          (index) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: defaultPadding / 4),
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
          ),
        );
      },
    );
  }
}

class _FallbackPromoBanner extends StatelessWidget {
  const _FallbackPromoBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
      child: AspectRatio(
        aspectRatio: 1.87,
        child: Container(
          padding: const EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color: const Color(0xFF172033),
            borderRadius: BorderRadius.circular(defaultBorderRadius),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: warningColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'EXCLUSIVE DEALS',
                        style: TextStyle(
                          color: warningColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Up to 30% off',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Petroleum station supplies',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(defaultBorderRadius),
                ),
                child: const Icon(
                  Icons.local_gas_station_outlined,
                  color: warningColor,
                  size: 40,
                ),
              ),
            ],
          ),
        ),
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
