import 'package:flutter/material.dart';
import 'package:wrms.app/routes.dart';
import 'package:wrms.app/services/index.dart';
import 'package:provider/provider.dart';
import 'package:wrms.app/services/otp_service.dart';



class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});
  @override
  _ForgotPasswordForm createState() => _ForgotPasswordForm();
}

class _ForgotPasswordForm extends State<ForgotPasswordForm> {
  String? _value;
  bool _isLoading = false;
  final String _type = 'forgot_password_otp';
  bool _showModal=false;
  

  void sendMail() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final sendOtpResponse = await OtpService.sendOtp(_value!, _type);
      setState(() {
        _isLoading = false;
      });
      _showErrorModal(context, sendOtpResponse);
      Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, Routes.login);
      });
    } catch (e) {
      _showErrorModal(context, '$e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  void _showErrorModal(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                setState(() {
                  _showModal = false;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonWidth = screenWidth * 0.8;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
        title: Text("Forgot Password"),
        
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/forgotImage.png',
              width: 200.0,
              height: 200.0,
            ),
            const Text(
              "Forgotten your password? Enter your email address below, and we'll email instructions for setting a new one.",
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (String? value) {
                _value = value!;
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF313256),
                foregroundColor: Colors.white,
                fixedSize: Size(buttonWidth, 50),
              ),
              onPressed: _isLoading ? null : sendMail,
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : const Text('Send Verification Mail'),
            ),
          ],
        ),
      ),
    );
  }
}