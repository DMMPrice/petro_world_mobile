import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petro_world/constants.dart';
import 'package:petro_world/providers/providers.dart';

class AppBottomNavigationBar extends ConsumerWidget {
  const AppBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider);

    SvgPicture svgIcon(String src, {Color? color}) {
      return SvgPicture.asset(
        src,
        height: 24,
        colorFilter: ColorFilter.mode(
            color ??
                Theme.of(context).iconTheme.color!.withValues(alpha: 
                    Theme.of(context).brightness == Brightness.dark ? 0.3 : 1),
            BlendMode.srcIn),
      );
    }

    return Container(
      padding: const EdgeInsets.only(top: defaultPadding / 2),
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : const Color(0xFF101015),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(navigationProvider.notifier).setIndex(index);
          // If we are not in EntryPoint, we might want to pop back to it
          // However, if we just update the index, the EntryPoint (which is still in the stack)
          // will update its body. We just need to pop the current screen if it's a details screen.
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF101015),
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        selectedItemColor: const Color.fromARGB(255, 0, 0, 0),
        unselectedItemColor: const Color(0xFF979797),
        items: [
          BottomNavigationBarItem(
            icon: svgIcon("assets/icons/home.svg"),
            activeIcon: svgIcon("assets/icons/home-filled.svg", color: const Color.fromARGB(255, 0, 0, 0)),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: svgIcon("assets/icons/Search.svg"),
            activeIcon: svgIcon("assets/icons/Search.svg", color: const Color.fromARGB(255, 0, 0, 0)),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: svgIcon("assets/icons/heart.svg"),
            activeIcon: svgIcon("assets/icons/heart-filled.svg", color: Colors.red),
            label: "Wishlist",
          ),
          BottomNavigationBarItem(
            icon: svgIcon("assets/icons/Bag.svg"),
            activeIcon: svgIcon("assets/icons/bag_full.svg", color: const Color.fromARGB(255, 0, 0, 0)),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: svgIcon("assets/icons/Profile.svg"),
            activeIcon: svgIcon("assets/icons/Profile-filled.svg", color: const Color.fromARGB(255, 0, 0, 0)),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
