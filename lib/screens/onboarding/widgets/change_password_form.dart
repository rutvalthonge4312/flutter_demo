import 'package:flutter/material.dart';
import 'package:wrms.app/services/profile_service.dart';
import 'package:provider/provider.dart';
import 'package:wrms.app/models/index.dart';
import 'dart:async';

class ChangePassword extends StatefulWidget {
  final UserModel userModel;
  const ChangePassword({Key? key, required this.userModel}) : super(key: key);

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  late UserModel userModel;
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _otpController;
  final _formKey = GlobalKey<FormState>();
  bool _isOTPSent = false;
  bool _showResendButton = false;
  bool _verifyingOTP = false;
  Timer? _timer;
  int _timerSeconds = 30;
  bool _sendingMobileOTP = false;
  bool _sendingEmailOTP = false;
  String _otpType = '';
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    userModel = widget.userModel;
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _otpController = TextEditingController();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _sendOTP(String otpType) async {
    setState(() {
      if (otpType == 'M') {
        _sendingMobileOTP = true;
        _otpType = 'M';
      } else if (otpType == 'E') {
        _sendingEmailOTP = true;
        _otpType = 'E';
      }
    });

    final token = userModel.token;
    final data = {
      'send_otp': otpType,
      'old_password': _oldPasswordController.text,
      'new_password1': _newPasswordController.text,
      'new_password2': _confirmPasswordController.text,
    };

    try {
      final message = await ProfileService.changePassword(token, data);
      setState(() {
        _showErrorModal(context, '$message');
        _isOTPSent = true;
        _startTimer();
      });
    } catch (e) {
      setState(() {
        _showErrorModal(context, '$e');
      });
    } finally {
      setState(() {
        if (otpType == 'M') {
          _sendingMobileOTP = false;
        } else if (otpType == 'E') {
          _sendingEmailOTP = false;
        }
      });
    }
  }

  void _startTimer() {
    setState(() {
      _timerSeconds = 30;
      _showResendButton = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timerSeconds > 0) {
          _timerSeconds--;
        } else {
          _showResendButton = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _resendOtp() async {
    await _sendOTP(_otpType);
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.isEmpty) {
      _showErrorModal(context, 'Please enter the OTP');
      return;
    }
    setState(() {
      _verifyingOTP = true;
    });
    final token = userModel.token;
    final data = {'otp': _otpController.text};
    try {
      final message = await ProfileService.changePasswordOTP(token, data);
      _showErrorModal(context, message);
      setState(() {
        _isOTPSent = false;
        _otpController.clear();
        _oldPasswordController.clear();
         _newPasswordController.clear();
        _confirmPasswordController.clear();
      });
    } catch (e) {
      _showErrorModal(context, '$e');
    } finally {
      setState(() {
        _verifyingOTP = false;
      });
    }
  }

  void _showErrorModal(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
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
    return Scaffold(
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double cardWidth = constraints.maxWidth > 600 ? 600 : constraints.maxWidth * 0.9;

            return Container(
              padding:EdgeInsets.fromLTRB(16.0, 1.0, 16.0, 16.0),
              child: Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: cardWidth),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Center(
                            child: Text(
                              'Change Your Password',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          SizedBox(height: 20),
                          _buildTextField(
                            label: 'Old Password',
                            controller: _oldPasswordController,
                            obscureText: _obscureOldPassword,
                            suffixIcon: IconButton(
                              icon: Icon(_obscureOldPassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _obscureOldPassword = !_obscureOldPassword;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 20),
                          _buildTextField(
                            label: 'New Password',
                            controller: _newPasswordController,
                            obscureText: _obscureNewPassword,
                            suffixIcon: IconButton(
                              icon: Icon(_obscureNewPassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 20),
                          _buildTextField(
                            label: 'Confirm New Password',
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            suffixIcon: IconButton(
                              icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          if (_isOTPSent) ...[
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    label: 'OTP',
                                    controller: _otpController,
                                  ),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: _showResendButton ? _resendOtp : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF313256),
                                    foregroundColor: Colors.white,
                                    minimumSize: Size(100, 50),
                                  ),
                                  child: Text(
                                    _showResendButton
                                        ? 'Resend OTP'
                                        : 'Resend in $_timerSeconds s',
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _verifyingOTP ? null : _verifyOTP,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF313256),
                                foregroundColor: Colors.white,
                                minimumSize: Size(double.infinity, 50),
                              ),
                              child: _verifyingOTP
                                  ? CircularProgressIndicator(color: Colors.white)
                                  : Text('Verify OTP'),
                            ),
                          ] else ...[
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _sendingMobileOTP || _sendingEmailOTP ? null : () => _sendOTP('M'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF313256),
                                foregroundColor: Colors.white,
                                minimumSize: Size(double.infinity, 50),
                              ),
                              child: _sendingMobileOTP || _sendingEmailOTP
                                  ? CircularProgressIndicator(color: Colors.white)
                                  : Text('Send Mobile OTP'),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _sendingMobileOTP || _sendingEmailOTP ? null : () => _sendOTP('E'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF313256),
                                foregroundColor: Colors.white,
                                minimumSize: Size(double.infinity, 50),
                              ),
                              child: _sendingMobileOTP || _sendingEmailOTP
                                  ? CircularProgressIndicator(color: Colors.white)
                                  : Text('Send Email OTP'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          suffixIcon: suffixIcon,
        ),
        obscureText: obscureText,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a value';
          }
          return null;
        },
      ),
    );
  }
}
