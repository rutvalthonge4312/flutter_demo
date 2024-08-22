import 'package:flutter/material.dart';
import 'package:wrms.app/routes.dart';
import 'package:wrms.app/screens/onboarding/widgets/signup_form.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, Routes.login);
          },
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SignupForm(),
      ),
    );
  }
}
