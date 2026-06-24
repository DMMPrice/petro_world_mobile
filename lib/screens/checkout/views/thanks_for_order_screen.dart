import 'package:flutter/material.dart';
import 'package:petro_world/constants.dart';
import 'package:petro_world/route/route_constants.dart';

class ThanksForOrderScreen extends StatelessWidget {
  const ThanksForOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Image.asset(
              Theme.of(context).brightness == Brightness.light
                  ? "assets/Illustration/Success_lightTheme.png"
                  : "assets/Illustration/Success_darkTheme.png",
              width: MediaQuery.of(context).size.width * 0.7,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.check_circle_outline,
                size: 128,
                color: successColor,
              ),
            ),
            const Spacer(),
            Text(
              "Thanks for your order!",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: defaultPadding / 2),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Text(
                "Your order has been placed successfully. You can track your order in the 'Orders' section.",
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(flex: 2),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, entryPointScreenRoute, (route) => false);
                },
                child: const Text("Back to Home"),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
