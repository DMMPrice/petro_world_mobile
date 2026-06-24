import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:petro_world/constants.dart';
import 'package:petro_world/route/screen_export.dart';
import 'package:petro_world/services/api_service.dart';
import 'components/profile_card.dart';
import 'components/profile_menu_item_list_tile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petro_world/providers/providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ListView(
        children: [
          FutureBuilder<Map<String, dynamic>?>(
            future: ApiService.instance.getProfile(),
            builder: (context, snapshot) {
              final profile = snapshot.data;
              if (!ApiService.instance.isLoggedIn) {
                return ProfileCard(
                  name: "Guest User",
                  email: "Log in to place orders",
                  imageSrc: "",
                  press: () {
                    Navigator.pushNamed(context, logInScreenRoute);
                  },
                );
              }

              return ProfileCard(
                name: profile?['first_name'] ?? "User",
                email: ApiService.instance.currentUser?.email ?? "No email",
                imageSrc: profile?['avatar_url'] ?? "",
                press: () {
                  Navigator.pushNamed(context, userInfoScreenRoute);
                },
              );
            },
          ),
          const SizedBox(height: defaultPadding * 1.5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Text(
              "Account",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const SizedBox(height: defaultPadding / 2),
          ProfileMenuListTile(
            text: "Orders",
            svgSrc: "assets/icons/Order.svg",
            press: () {
              if (!ApiService.instance.isLoggedIn) {
                Navigator.pushNamed(context, logInScreenRoute);
              } else {
                Navigator.pushNamed(context, ordersScreenRoute);
              }
            },
          ),
          ProfileMenuListTile(
            text: "Wishlist",
            svgSrc: "assets/icons/Wishlist.svg",
            press: () {
              if (!ApiService.instance.isLoggedIn) {
                Navigator.pushNamed(context, logInScreenRoute);
              } else {
                ref.read(navigationProvider.notifier).setIndex(2);
              }
            },
          ),
          ProfileMenuListTile(
            text: "Addresses",
            svgSrc: "assets/icons/Address.svg",
            press: () {
              if (!ApiService.instance.isLoggedIn) {
                Navigator.pushNamed(context, logInScreenRoute);
              } else {
                Navigator.pushNamed(context, addressesScreenRoute);
              }
            },
          ),
          const SizedBox(height: defaultPadding),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding / 2),
            child: Text(
              "Help & Support",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ProfileMenuListTile(
            text: "Get Help",
            svgSrc: "assets/icons/Help.svg",
            press: () {
              Navigator.pushNamed(context, getHelpScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "FAQ",
            svgSrc: "assets/icons/FAQ.svg",
            press: () {
              Navigator.pushNamed(context, faqScreenRoute);
            },
            isShowDivider: false,
          ),
          const SizedBox(height: defaultPadding),

          // Log Out / Log In
          ListTile(
            onTap: () async {
              if (!ApiService.instance.isLoggedIn) {
                Navigator.pushNamed(context, logInScreenRoute);
              } else {
                await ApiService.instance.logout();
              }
            },
            minLeadingWidth: 24,
            leading: SvgPicture.asset(
              !ApiService.instance.isLoggedIn 
                ? "assets/icons/Edit Square.svg" 
                : "assets/icons/Logout.svg",
              height: 24,
              width: 24,
              colorFilter: ColorFilter.mode(
                !ApiService.instance.isLoggedIn ? primaryColor : errorColor,
                BlendMode.srcIn,
              ),
            ),
            title: Text(
              !ApiService.instance.isLoggedIn ? "Log In" : "Log Out",
              style: TextStyle(
                color: !ApiService.instance.isLoggedIn ? primaryColor : errorColor, 
                fontSize: 14, 
                height: 1
              ),
            ),
          )
        ],
      ),
    );
  }
}
