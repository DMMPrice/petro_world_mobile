import 'package:flutter/material.dart';
import 'package:petro_world/constants.dart';
import 'package:petro_world/route/route_constants.dart';
import 'package:petro_world/services/api_service.dart';

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
  bool _isLoading = false;
  String _email = '';
  String _code = '';
  String _password = '';
  String _confirmPassword = '';
  String? _debugCode;

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);
    try {
      if (_currentStep == 0) {
        final code = await ApiService.instance.requestPasswordReset(_email);
        if (!mounted) return;
        setState(() {
          _debugCode = code;
          _currentStep = 1;
        });
        if (code != null && code.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification code: $code')),
          );
        }
      } else if (_currentStep == 1) {
        setState(() => _currentStep = 2);
      } else {
        if (_password != _confirmPassword) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Passwords do not match')),
          );
          return;
        }
        await ApiService.instance.resetPassword(
          email: _email,
          code: _code,
          password: _password,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset successfully')),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          logInScreenRoute,
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
                onPressed: _isLoading ? null : _handleContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: whiteColor,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(defaultBorderRadius),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_currentStep < 2 ? "Continue" : "Reset Password"),
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
              onEmailSaved: (value) => _email = value?.trim() ?? '',
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
              _debugCode == null
                  ? "Please enter the 4-digit code sent to your email address."
                  : "Please enter the 4-digit code shown in the previous message.",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: blackColor60,
                  ),
            ),
            const SizedBox(height: defaultPadding),
            OtpForm(
              formKey: _formKey,
              onSaved: (value) => _code = value?.trim() ?? '',
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
              onPasswordSaved: (value) => _password = value ?? '',
              onConfirmPasswordSaved: (value) => _confirmPassword = value ?? '',
            ),
          ],
        );
      default:
        return Container();
    }
  }
}
