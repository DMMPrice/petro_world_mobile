import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop/screens/auth/views/components/sign_up_form.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/providers/auth_provider.dart';
import 'package:shop/services/api_service.dart';

import '../../../constants.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _firstName;
  String? _lastName;
  String? _email;
  String? _password;
  bool _isLoading = false;
  bool _agreedToTerms = false;

  Future<void> _signUp() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You must agree to the Terms of service & privacy policy.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        await ref.read(authProvider.notifier).register(
          email: _email!,
          password: _password!,
          firstName: _firstName!,
          lastName: _lastName ?? '',
        );

        final authState = ref.read(authProvider);
        if (authState.hasError) {
          final error = authState.error;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error is ApiException ? error.message : 'Registration failed'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Welcome to PETRO WORLD!'),
              backgroundColor: successColor,
            ),
          );
          Navigator.of(context).pushNamedAndRemoveUntil(
            entryPointScreenRoute,
            (route) => false,
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error is ApiException ? error.message : 'Unexpected error occurred'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: defaultPadding),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              ),
              const SizedBox(height: defaultPadding),
              Center(
                child: Image.asset(
                  "assets/logo/logo.png",
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: defaultPadding * 3),
              Text(
                "Create Account",
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: navyColor,
                    ),
              ),
              const SizedBox(height: defaultPadding / 2),
              Text(
                "Join PETRO WORLD for exclusive deals",
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: blackColor60,
                    ),
              ),
              const SizedBox(height: defaultPadding * 2),
              SignUpForm(
                formKey: _formKey,
                onFirstNameSaved: (value) => _firstName = value,
                onLastNameSaved: (value) => _lastName = value,
                onEmailSaved: (value) => _email = value,
                onPasswordSaved: (value) => _password = value,
              ),
              const SizedBox(height: defaultPadding),
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      onChanged: (value) {
                        setState(() {
                          _agreedToTerms = value ?? false;
                        });
                      },
                      value: _agreedToTerms,
                      activeColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: defaultPadding / 2),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: "I agree with the ",
                        children: [
                          TextSpan(
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushNamed(context, termsOfServicesScreenRoute);
                              },
                            text: "Terms of service",
                            style: const TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(text: " & "),
                          const TextSpan(
                            text: "privacy policy",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  )
                ],
              ),
              const SizedBox(height: defaultPadding * 2),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: whiteColor,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(defaultBorderRadius),
                        ),
                      ),
                      child: const Text("Create Account"),
                    ),
              const SizedBox(height: defaultPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, logInScreenRoute);
                    },
                    child: const Text(
                      "Log in",
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              const SizedBox(height: defaultPadding * 2),
            ],
          ),
        ),
      ),
    );
  }
}
