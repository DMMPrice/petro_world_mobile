import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/route_constants.dart';

import 'components/password_recovery_form.dart';
import 'components/otp_form.dart';
import 'components/reset_password_form.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _currentStep++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Password Recovery"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            children: [
              Image.asset(
                _getIllustration(),
                height: MediaQuery.of(context).size.height * 0.3,
              ),
              const SizedBox(height: defaultPadding),
              _buildStepContent(),
              const SizedBox(height: defaultPadding * 2),
              ElevatedButton(
                onPressed: () {
                  if (_currentStep < 2) {
                    _nextStep();
                  } else {
                    // Final step
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      logInScreenRoute,
                      (route) => false,
                    );
                  }
                },
                child: Text(_currentStep < 2 ? "Continue" : "Reset Password"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getIllustration() {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    switch (_currentStep) {
      case 0:
        return isDark
            ? "assets/Illustration/Password_dark.png"
            : "assets/Illustration/Password.png";
      case 1:
        return "assets/Illustration/VerificationCode_dark.png";
      case 2:
        return isDark
            ? "assets/Illustration/Success_darkTheme.png"
            : "assets/Illustration/Success_lightTheme.png";
      default:
        return "assets/Illustration/Password.png";
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Forgot password",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: defaultPadding / 2),
            const Text(
              "Please enter your email address. You will receive a link to create a new password via email.",
            ),
            const SizedBox(height: defaultPadding),
            PasswordRecoveryForm(
              formKey: _formKey,
              onEmailSaved: (value) {},
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Verification code",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: defaultPadding / 2),
            const Text(
              "Please enter the 4-digit code sent to your email address.",
            ),
            const SizedBox(height: defaultPadding),
            OtpForm(
              formKey: _formKey,
              onSaved: (value) {},
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Reset password",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: defaultPadding / 2),
            const Text(
              "Your new password must be different from previous used passwords.",
            ),
            const SizedBox(height: defaultPadding),
            ResetPasswordForm(
              formKey: _formKey,
              onPasswordSaved: (value) {},
              onConfirmPasswordSaved: (value) {},
            ),
          ],
        );
      default:
        return Container();
    }
  }
}
