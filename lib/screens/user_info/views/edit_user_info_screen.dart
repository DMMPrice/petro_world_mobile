import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/constants.dart';

class EditUserInfoScreen extends StatelessWidget {
  const EditUserInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              "assets/icons/info.svg",
              colorFilter: ColorFilter.mode(
                  Theme.of(context).iconTheme.color!, BlendMode.srcIn),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Column(
                  children: [
                    const SizedBox(height: defaultPadding),
                    const EditAvatar(),
                    const SizedBox(height: defaultPadding * 2),
                    Form(
                      child: Column(
                        children: [
                          TextFormField(
                            initialValue: "Sepide Moqadasi",
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(defaultBorderRadious),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(defaultBorderRadious),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(defaultBorderRadious),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(defaultPadding * 0.75),
                                child: SvgPicture.asset(
                                  "assets/icons/Profile.svg",
                                  height: 24,
                                  width: 24,
                                  colorFilter: ColorFilter.mode(
                                      Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.7),
                                      BlendMode.srcIn),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: defaultPadding),
                          TextFormField(
                            initialValue: "theflutterway@gmail.com",
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(defaultBorderRadious),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(defaultBorderRadious),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(defaultBorderRadious),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(defaultPadding * 0.75),
                                child: SvgPicture.asset(
                                  "assets/icons/Message.svg",
                                  height: 24,
                                  width: 24,
                                  colorFilter: ColorFilter.mode(
                                      Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.7),
                                      BlendMode.srcIn),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: defaultPadding),
                          TextFormField(
                            initialValue: "01/3/1999",
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(defaultBorderRadious),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(defaultBorderRadious),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(defaultBorderRadious),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(defaultPadding * 0.75),
                                child: SvgPicture.asset(
                                  "assets/icons/Calender.svg",
                                  height: 24,
                                  width: 24,
                                  colorFilter: ColorFilter.mode(
                                      Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.7),
                                      BlendMode.srcIn),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: defaultPadding),
                          TextFormField(
                            initialValue: "+1-202-555-0162",
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(defaultBorderRadious),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(defaultBorderRadious),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(defaultBorderRadious),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(defaultPadding * 0.75),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/Call.svg",
                                      height: 24,
                                      width: 24,
                                      colorFilter: ColorFilter.mode(
                                          Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.7),
                                          BlendMode.srcIn),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text("+1"),
                                    const SizedBox(width: 8),
                                    Container(
                                      height: 24,
                                      width: 1,
                                      color: Theme.of(context).dividerColor,
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Done"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditAvatar extends StatelessWidget {
  const EditAvatar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage("https://i.imgur.com/IXnwbLk.png"),
            ),
            Positioned(
              right: -5,
              bottom: -5,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    "assets/icons/Edit-Bold.svg",
                    height: 16,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: defaultPadding),
        TextButton(
          onPressed: () {},
          child: const Text(
            "Edit photo",
            style: TextStyle(color: primaryColor),
          ),
        )
      ],
    );
  }
}
