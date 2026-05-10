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
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        leading: const BackButton(color: navyColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: defaultPadding),
              Center(
                child: Image.asset(
                  "assets/logo/logo.png",
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: defaultPadding * 2),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: whiteColor,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(defaultBorderRadius),
                  ),
                ),
                child: Text(_currentStep < 2 ? "Continue" : "Reset Password"),
              ),
              const SizedBox(height: defaultPadding),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Forgot password",
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: navyColor,
                  ),
            ),
            const SizedBox(height: defaultPadding / 2),
            Text(
              "Please enter your email address. You will receive a link to create a new password via email.",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: blackColor60,
                  ),
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
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: navyColor,
                  ),
            ),
            const SizedBox(height: defaultPadding / 2),
            Text(
              "Please enter the 4-digit code sent to your email address.",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: blackColor60,
                  ),
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
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: navyColor,
                  ),
            ),
            const SizedBox(height: defaultPadding / 2),
            Text(
              "Your new password must be different from previous used passwords.",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: blackColor60,
                  ),
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
