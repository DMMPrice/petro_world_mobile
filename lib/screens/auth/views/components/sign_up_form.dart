import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../constants.dart';

class SignUpForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final FormFieldSetter<String> onFirstNameSaved;
  final FormFieldSetter<String> onLastNameSaved;
  final FormFieldSetter<String> onEmailSaved;
  final FormFieldSetter<String> onPasswordSaved;

  const SignUpForm({
    super.key,
    required this.formKey,
    required this.onFirstNameSaved,
    required this.onLastNameSaved,
    required this.onEmailSaved,
    required this.onPasswordSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            onSaved: onFirstNameSaved,
            validator: (value) => (value == null || value.isEmpty) ? "First name is required" : null,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: "First Name",
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                child: Icon(
                  Icons.person_outline,
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.3),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            onSaved: onLastNameSaved,
            validator: (value) => (value == null || value.isEmpty) ? "Last name is required" : null,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: "Last Name",
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                child: Icon(
                  Icons.person_outline,
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.3),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            onSaved: onEmailSaved,
            validator: emaildValidator,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "Email address",
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                child: SvgPicture.asset(
                  "assets/icons/Message.svg",
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.3) ?? Colors.grey,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            onSaved: onPasswordSaved,
            validator: passwordValidator,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Password",
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                child: SvgPicture.asset(
                  "assets/icons/Lock.svg",
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.3) ?? Colors.grey,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
