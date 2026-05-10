import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'constants.dart';
import 'route/screen_export.dart';
import 'components/app_bottom_navigation_bar.dart';

import 'components/notification_badge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/providers.dart';
import 'services/supabase_service.dart';

class EntryPoint extends ConsumerStatefulWidget {
  const EntryPoint({super.key});

  @override
  ConsumerState<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends ConsumerState<EntryPoint> {
  final List _pages = const [
    HomeScreen(),
    SearchScreen(),
    BookmarkScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: const SizedBox(),
        leadingWidth: 0,
        centerTitle: false,
        title: Image.asset(
          "assets/logo/logo.png",
          height: 32,
          fit: BoxFit.contain,
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  if (SupabaseService.client.auth.currentUser == null) {
                    Navigator.pushNamed(context, logInScreenRoute);
                  } else {
                    Navigator.pushNamed(context, notificationsScreenRoute);
                  }
                },
                icon: SvgPicture.asset(
                  "assets/icons/Notification.svg",
                  height: 24,
                  colorFilter: ColorFilter.mode(
                      Theme.of(context).textTheme.bodyLarge!.color!,
                      BlendMode.srcIn),
                ),
              ),
              const NotificationBadge(),
            ],
          ),
        ],
      ),
      body: PageTransitionSwitcher(
        duration: defaultDuration,
        transitionBuilder: (child, animation, secondAnimation) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondAnimation,
            child: child,
          );
        },
        child: _pages[currentIndex],
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}
