import 'package:flutter/material.dart';
import 'package:petro_world/constants.dart';
import 'package:petro_world/route/route_constants.dart';

class EnableNotificationScreen extends StatelessWidget {
  const EnableNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            children: [
              const Spacer(),
              Image.asset(
                Theme.of(context).brightness == Brightness.light
                    ? "assets/Illustration/TurnOnNotification_lightTheme.png"
                    : "assets/Illustration/TurnOnNotification_darkTheme.png",
                height: MediaQuery.of(context).size.height * 0.35,
              ),
              const Spacer(flex: 2),
              Text(
                "Enable Notifications",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: defaultPadding),
              const Text(
                "Enable notifications to stay updated with your order status and exclusive offers.",
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 2),
              ElevatedButton(
                onPressed: () {
                  // In a real app, this would trigger permission request
                  Navigator.pushReplacementNamed(context, entryPointScreenRoute);
                },
                child: const Text("Allow Notifications"),
              ),
              const SizedBox(height: defaultPadding),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, entryPointScreenRoute);
                },
                child: Text(
                  "Not now",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
