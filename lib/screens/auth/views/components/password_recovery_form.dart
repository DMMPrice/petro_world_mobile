import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../constants.dart';

class PasswordRecoveryForm extends StatelessWidget {
  const PasswordRecoveryForm({
    super.key,
    required this.formKey,
    required this.onEmailSaved,
  });

  final GlobalKey<FormState> formKey;
  final FormFieldSetter<String> onEmailSaved;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: TextFormField(
        onSaved: onEmailSaved,
        validator: emaildValidator.call,
        textInputAction: TextInputAction.done,
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
                  Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.3),
                  BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}
