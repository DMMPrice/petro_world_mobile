import 'package:flutter/material.dart';
import 'package:petro_world/constants.dart';
import 'package:petro_world/route/route_constants.dart';

import 'package:petro_world/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:petro_world/components/network_image_with_loader.dart';

class UserInfoScreen extends StatelessWidget {
  const UserInfoScreen({super.key});

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    var isLoading = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: !isLoading,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            InputDecoration fieldDecoration(String hint) {
              return InputDecoration(
                hintText: hint,
                filled: true,
                fillColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.55),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primaryColor),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              );
            }

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Change password',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: blackColor,
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: currentController,
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          decoration: fieldDecoration('Current password'),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Current password is required'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: newController,
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          decoration: fieldDecoration('New password'),
                          validator: passwordValidator.call,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: confirmController,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          decoration: fieldDecoration('Confirm password'),
                          validator: (value) {
                            if (value != newController.text) {
                              return pasNotMatchErrorText;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isLoading
                                    ? null
                                    : () => Navigator.pop(dialogContext),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryColor,
                                  side: const BorderSide(color: primaryColor),
                                  minimumSize: const Size.fromHeight(46),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () async {
                                        if (!formKey.currentState!.validate()) {
                                          return;
                                        }
                                        setDialogState(() => isLoading = true);
                                        try {
                                          await ApiService.instance
                                              .changePassword(
                                            currentPassword:
                                                currentController.text,
                                            newPassword: newController.text,
                                          );
                                          if (!context.mounted) return;
                                          Navigator.pop(dialogContext);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Password changed successfully',
                                              ),
                                            ),
                                          );
                                        } catch (e) {
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Unable to change password: $e',
                                              ),
                                            ),
                                          );
                                        } finally {
                                          if (context.mounted) {
                                            setDialogState(
                                                () => isLoading = false);
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(46),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Update'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
  }

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
                  trailingText: (profile?['dob'] != null &&
                          profile!['dob'].toString().isNotEmpty)
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
                  trailingText: (profile?['phone'] ?? profile?['phone_number'])
                          ?.toString() ??
                      "Not set",
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
                    _showChangePasswordDialog(context);
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
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            child:
                image.isNotEmpty && !image.contains('i.imgur.com/IXnwbLk.png')
                    ? ClipOval(
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: NetworkImageWithLoader(
                            image,
                            radius: 0,
                          ),
                        ),
                      )
                    : const Icon(Icons.person, color: Colors.grey),
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
