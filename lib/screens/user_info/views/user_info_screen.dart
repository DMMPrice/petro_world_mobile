import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/route_constants.dart';

import 'package:shop/services/api_service.dart';
import 'package:intl/intl.dart';

class UserInfoScreen extends StatelessWidget {
  const UserInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, editUserInfoScreenRoute);
            },
            child: const Text(
              "Edit",
              style: TextStyle(color: primaryColor),
            ),
          )
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: ApiService.instance.getProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = snapshot.data;
          final user = ApiService.instance.currentUser;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: defaultPadding),
                ProfileInfo(
                  name: profile?['first_name'] != null 
                      ? "${profile!['first_name']} ${profile['last_name'] ?? ''}"
                      : "User",
                  email: user?.email ?? "No email",
                  image: profile?['avatar_url'] ?? "",
                ),
                const SizedBox(height: defaultPadding * 2),
                UserInfoListTile(
                  title: "Name",
                  trailingText: profile?['first_name'] != null 
                      ? "${profile!['first_name']} ${profile['last_name'] ?? ''}"
                      : "Not set",
                ),
                UserInfoListTile(
                  title: "Date of birth",
                  trailingText: (profile?['dob'] != null && profile!['dob'].toString().isNotEmpty)
                      ? (() {
                          try {
                            DateTime dbDate = DateTime.parse(profile['dob']);
                            return DateFormat('dd/MM/yyyy').format(dbDate);
                          } catch (e) {
                            return profile['dob'].toString();
                          }
                        })()
                      : "Not set",
                ),
                UserInfoListTile(
                  title: "Phone number",
                  trailingText: profile?['phone_number'] ?? "Not set",
                ),
                UserInfoListTile(
                  title: "Gender",
                  trailingText: profile?['gender'] ?? "Not set",
                ),
                UserInfoListTile(
                  title: "Email",
                  trailingText: user?.email ?? "Not set",
                ),
                ListTile(
                  title: const Text(
                    "Password",
                    style: TextStyle(fontSize: 14),
                  ),
                  trailing: const Text(
                    "Change password",
                    style: TextStyle(
                      fontSize: 14,
                      color: primaryColor,
                    ),
                  ),
                  onTap: () {
                    // Navigate to change password
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProfileInfo extends StatelessWidget {
  const ProfileInfo({
    super.key,
    required this.name,
    required this.email,
    required this.image,
  });

  final String name, email, image;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            backgroundImage: image.isNotEmpty && !image.contains('i.imgur.com/IXnwbLk.png')
                ? NetworkImage(image)
                : null,
            child: image.isEmpty || image.contains('i.imgur.com/IXnwbLk.png')
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  email,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class UserInfoListTile extends StatelessWidget {
  const UserInfoListTile({
    super.key,
    required this.title,
    required this.trailingText,
  });

  final String title, trailingText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: const TextStyle(fontSize: 14),
          ),
          trailing: Text(
            trailingText,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
