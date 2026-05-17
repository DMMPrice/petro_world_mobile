import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../constants.dart';

class ResetPasswordForm extends StatelessWidget {
  const ResetPasswordForm({
    super.key,
    required this.formKey,
    required this.onPasswordSaved,
    required this.onConfirmPasswordSaved,
  });

  final GlobalKey<FormState> formKey;
  final FormFieldSetter<String> onPasswordSaved;
  final FormFieldSetter<String> onConfirmPasswordSaved;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            onSaved: onPasswordSaved,
            validator: passwordValidator.call,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "New password",
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                child: SvgPicture.asset(
                  "assets/icons/Lock.svg",
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                      Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.3),
                      BlendMode.srcIn),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            onSaved: onConfirmPasswordSaved,
            validator: (value) {
              // Usually we'd compare with the password field
              return null;
            },
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Confirm password",
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                child: SvgPicture.asset(
                  "assets/icons/Lock.svg",
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                      Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.3),
                      BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
