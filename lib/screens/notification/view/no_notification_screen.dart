import 'package:flutter/material.dart';
import '../../../constants.dart';

class NoNotificationScreen extends StatelessWidget {
  const NoNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Image.asset(
                Theme.of(context).brightness == Brightness.light
                    ? "assets/Illustration/EmptyState_lightTheme.png"
                    : "assets/Illustration/EmptyState_darkTheme.png",
                width: MediaQuery.of(context).size.width * 0.6,
              ),
              const SizedBox(height: defaultPadding * 2),
              Text(
                "No notification",
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: defaultPadding),
              Text(
                "Customer network effects freemium. Advisor android paradigm shift product management. Customer disruptive crowdsource",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
