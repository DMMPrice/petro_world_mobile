import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/route_constants.dart';

import 'components/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _email;
  String? _password;
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        await Supabase.instance.client.auth.signInWithPassword(
          email: _email!,
          password: _password!,
        );
        // AuthGate will handle redirection automatically upon auth state change
      } on AuthException catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message), backgroundColor: Theme.of(context).colorScheme.error),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Unexpected error occurred'), backgroundColor: Theme.of(context).colorScheme.error),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
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
                "Welcome Back",
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: navyColor,
                    ),
              ),
              const SizedBox(height: defaultPadding / 2),
              Text(
                "Login to your PETRO WORLD account",
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: blackColor60,
                    ),
              ),
              const SizedBox(height: defaultPadding * 2),
              LogInForm(
                formKey: _formKey,
                onEmailSaved: (value) => _email = value,
                onPasswordSaved: (value) => _password = value,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  child: const Text(
                    "Forgot password?",
                    style: TextStyle(color: primaryColor),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, passwordRecoveryScreenRoute);
                  },
                ),
              ),
              const SizedBox(height: defaultPadding),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: whiteColor,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(defaultBorderRadius),
                        ),
                      ),
                      child: const Text("Log in"),
                    ),
              const SizedBox(height: defaultPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, signUpScreenRoute);
                    },
                    child: const Text(
                      "Sign up",
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              const SizedBox(height: defaultPadding),
            ],
          ),
        ),
      ),
    );
  }
}
