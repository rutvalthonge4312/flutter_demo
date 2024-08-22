import 'package:flutter/material.dart';
import 'package:wrms.app/screens/otp_login/widgets/otp_form.dart';

class Otp extends StatelessWidget {
  const Otp({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter OTP'),
        leading: IconButton(
          icon:const Icon(Icons.arrow_back), 
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/mobile-login');
          },
        ),
      ),
      body:const Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please enter the OTP sent to your mobile number:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            OtpForm(),
          ],
        ),
      ),
    );
  }
}
