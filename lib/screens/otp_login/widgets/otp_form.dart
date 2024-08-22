import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wrms.app/models/index.dart';
import 'package:wrms.app/routes.dart';
import 'package:wrms.app/screens/index.dart';
import 'package:wrms.app/services/auth_service.dart';
import 'package:wrms.app/services/otp_service.dart';

class OtpForm extends StatefulWidget {
  const OtpForm({super.key});

  @override
  _OtpForm createState() => _OtpForm();
}

class _OtpForm extends State<OtpForm> {
  String otp = '';
  String? mobileNumber;
  bool _isLoadingConfirm = false;
  bool _isLoadingResend = false;
  bool _showModal = false;
  String? type;
  String? value;
  
  void _sendOtp() async {
    setState(() {
      _isLoadingResend = true; // Use this flag for resend button
    });

    type = 'phone_number';
    value = mobileNumber;

    try {
      final sendOtpResponse = await OtpService.sendOtp(value!, type!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP resent successfully')),
      );
      Navigator.pushReplacementNamed(context, Routes.otpEnter, arguments: mobileNumber);
    } catch (e) {
      if (e is StateError && e.toString().contains('mounted')) {
        print('Widget disposed before operation completes');
      } else {
        print('Send OTP Failed: $e');
        _showErrorModalDialog(context, '$e');
      }
    } finally {
      setState(() {
        _isLoadingResend = false;
      });
    }
  }

  void _resendOtp() async {
   _sendOtp();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    if (args != null && mobileNumber == null) {
      setState(() {
        mobileNumber = args;
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

  void _submitOtp() async {
    setState(() {
      _isLoadingConfirm = true;
    });
    try {
      final loginResponse = await AuthService.loginByMobile(otp, mobileNumber!);
      Provider.of<AuthModel>(context, listen: false).login(loginResponse!);
      Provider.of<UserModel>(context, listen: false).updateUserDetails(
        userName: loginResponse.userName,
        mobileNumber: loginResponse.mobileNumber,
        stationCode: loginResponse.stationCode,
        stationName: loginResponse.stationName,
        token: loginResponse.token,
        userType: loginResponse.userType,
        refreshToken: loginResponse.refreshToken,
      );
      Navigator.pushReplacementNamed(context, Routes.home);
    } catch (e) {
      if (e is StateError && e.toString().contains('mounted')) {
        print('Widget disposed before operation completes');
      } else {
        print('Login Error: $e');
        _showErrorModalDialog(context, '$e');
      }
    } finally {
      setState(() {
        _isLoadingConfirm = false;
      });
    }
  }

  void _handleOtpChange(String newOtp) {
    setState(() {
      otp = newOtp;
    });
  }

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonWidth = screenWidth * 0.4;
    return Form(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center, // Aligns the image to the right
            child: Image.asset(
              'assets/otpImage.png',
              width: 200.0,
              height: 200.0,
            ),
          ),
           OtpData(onOtpChanged: _handleOtpChange),
          Padding(
            padding: const EdgeInsets.only(top: 16.0), // Adjust the top padding as needed
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      fixedSize: Size(buttonWidth, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isLoadingConfirm ? null : _submitOtp,
                    child: _isLoadingConfirm
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Confirm'),
                  ),
                ),
                const SizedBox(width: 5),
                Center(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      fixedSize: Size(buttonWidth, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isLoadingResend ? null : _resendOtp,
                    child: _isLoadingResend
                        ? CircularProgressIndicator(color: Colors.blue)
                        : Text('Resend'),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
