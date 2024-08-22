import 'package:flutter/material.dart';
import 'package:wrms.app/routes.dart';
import 'package:wrms.app/screens/otp_login/widgets/mobile_filed.dart';
import 'package:wrms.app/services/otp_service.dart';

class MobileNumberScreen extends StatefulWidget {
  const MobileNumberScreen({super.key});

  @override
  _MobileNumberScreen createState() => _MobileNumberScreen();
}

class _MobileNumberScreen extends State<MobileNumberScreen> {
  late String _mobileNumber;
  String? value;
  String? type;
  bool _isLoading = false;
  bool _showErrorModal = false;
  String _errorMessage = '';

  void _sendOtp() async {
    setState(() {
      _isLoading = true;
    });

    type = 'phone_number';
    value = _mobileNumber;

    try {
      final sendOtpResponse = await OtpService.sendOtp(value!, type!);
      Navigator.pushReplacementNamed(context, Routes.otpEnter, arguments: _mobileNumber);
    } catch (e) {
      if (e is StateError && e.toString().contains('mounted')) {
        print('Widget disposed before operation completes');
      } else {
        print('Send Otp Failed: $e');
        _showErrorModalDialog(context, '$e');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorModalDialog(BuildContext context, String errorMessage) {
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
                  _showErrorModal = false;
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
        title: const Text('Mobile Login'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, Routes.login);
          },
        ),
      ),
      body:SingleChildScrollView(
       child:Padding(
        padding: EdgeInsets.all(16.0),
          child:Align(
            alignment: Alignment.center,
            child: Material(
              child: Column(
                children: [
                  
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/otpImage2.png',
                          width: 300.0,
                          height: 200.0,
                        ),
                        const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 24, // Change this value to your desired font size
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Please enter phone number'),
                        const SizedBox(height: 16),
                        MobileFiled(onSaved: (value) => _mobileNumber = value),
                        const SizedBox(height: 16),
                      ],
                    ),
                  
                  Padding(
                    padding: const EdgeInsets.all(16.0), // Add padding if needed
                    child: SizedBox(
                      width: buttonWidth,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF313256),
                          foregroundColor: Colors.white,
                          fixedSize: Size(buttonWidth, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _sendOtp,
                        child:_isLoading
                        ?const CircularProgressIndicator(color: Colors.white,)
                        :const Text('GENERATE OTP'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Add any other children you want inside the Stack here
        
      ),
      ),
    );
  }
}

