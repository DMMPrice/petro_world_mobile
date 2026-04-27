import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpForm extends StatelessWidget {
  const OtpForm({
    super.key,
    required this.formKey,
    required this.onSaved,
  });

  final GlobalKey<FormState> formKey;
  final FormFieldSetter<String> onSaved;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          4,
          (index) => SizedBox(
            height: 64,
            width: 64,
            child: TextFormField(
              onChanged: (value) {
                if (value.length == 1 && index < 3) {
                  FocusScope.of(context).nextFocus();
                }
              },
              onSaved: (value) {
                // This is a bit tricky for multiple fields, usually we'd have a controller per field
                // but for mock UI we can just use a simple approach or separate controllers.
                // For now, let's just make it look good.
              },
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
              keyboardType: TextInputType.number,
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                hintText: "0",
              ),
            ),
          ),
        ),
      ),
    );
  }
}
