import 'package:flutter/material.dart';
import 'package:wrms.app/screens/onboarding/widgets/forgot_password_form.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgotten Password'),
        automaticallyImplyLeading: true,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: ForgotPasswordForm(),
      ),
    );
  }
}