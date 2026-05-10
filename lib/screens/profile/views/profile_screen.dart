import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/screen_export.dart';
import 'package:shop/services/supabase_service.dart';
import 'components/profile_card.dart';
import 'components/profile_menu_item_list_tile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop/providers/providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ListView(
        children: [
          FutureBuilder<Map<String, dynamic>?>(
            future: SupabaseService.getProfile(),
            builder: (context, snapshot) {
              final profile = snapshot.data;
              final user = SupabaseService.client.auth.currentUser;
              
              if (user == null) {
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
                email: user.email ?? "No email",
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
              if (SupabaseService.client.auth.currentUser == null) {
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
              if (SupabaseService.client.auth.currentUser == null) {
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
              if (SupabaseService.client.auth.currentUser == null) {
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
              if (SupabaseService.client.auth.currentUser == null) {
                Navigator.pushNamed(context, logInScreenRoute);
              } else {
                await Supabase.instance.client.auth.signOut();
              }
            },
            minLeadingWidth: 24,
            leading: SvgPicture.asset(
              SupabaseService.client.auth.currentUser == null 
                ? "assets/icons/Edit Square.svg" 
                : "assets/icons/Logout.svg",
              height: 24,
              width: 24,
              colorFilter: ColorFilter.mode(
                SupabaseService.client.auth.currentUser == null ? primaryColor : errorColor,
                BlendMode.srcIn,
              ),
            ),
            title: Text(
              SupabaseService.client.auth.currentUser == null ? "Log In" : "Log Out",
              style: TextStyle(
                color: SupabaseService.client.auth.currentUser == null ? primaryColor : errorColor, 
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
