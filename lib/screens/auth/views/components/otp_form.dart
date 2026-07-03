import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpForm extends StatefulWidget {
  const OtpForm({
    super.key,
    required this.formKey,
    required this.onSaved,
  });

  final GlobalKey<FormState> formKey;
  final FormFieldSetter<String> onSaved;

  @override
  State<OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(4, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          4,
          (index) => SizedBox(
            height: 64,
            width: 64,
            child: TextFormField(
              controller: _controllers[index],
              onChanged: (value) {
                if (value.length == 1 && index < 3) {
                  FocusScope.of(context).nextFocus();
                } else if (value.isEmpty && index > 0) {
                  FocusScope.of(context).previousFocus();
                }
              },
              onSaved: (value) {
                if (index == 3) {
                  widget.onSaved(
                    _controllers.map((controller) => controller.text).join(),
                  );
                }
              },
              validator: (_) {
                final code =
                    _controllers.map((controller) => controller.text).join();
                if (code.length != 4) return '';
                return null;
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
