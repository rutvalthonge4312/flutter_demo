import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wrms.app/models/index.dart';
import 'package:wrms.app/services/profile_service.dart';
import 'dart:async';

class ChangeEmail extends StatefulWidget {
  final UserModel userModel;
  const ChangeEmail({Key? key, required this.userModel}) : super(key: key);
  @override
  _ChangeEmailState createState() => _ChangeEmailState();
}

class _ChangeEmailState extends State<ChangeEmail> {
  late UserModel userModel;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _currentEmailController;
  late TextEditingController _newEmailController;
  late TextEditingController _otpController;
  bool _isOTPSent = false;
  bool _isGeneratingOTP = false;
  bool _isVerifyingOTP = false;
  bool _showModal = false;
  late Timer? _timer;
  int _timerDuration = 30;
  bool _isResendEnabled = false;

  @override
  void initState() {
    super.initState();
    userModel = Provider.of<UserModel>(context, listen: false);
    _currentEmailController = TextEditingController();
    _newEmailController = TextEditingController();
    _otpController = TextEditingController();
    _getProfile();
  }

  @override
  void dispose() {
    _currentEmailController.dispose();
    _newEmailController.dispose();
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _getProfile() async {
    try {
      final token = userModel.token;
      final profileResponse = await ProfileService.getProfile(token);
      setState(() {
        _currentEmailController.text = profileResponse.user?.email ?? 'user@gmail.com';
      });
    } catch (e) {
         setState(() {
         _showErrorModal(context,'$e');
      });
    }
  }

  void _startTimer() {
    _isResendEnabled = false;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
    if(_timerDuration == 0) {
        setState(() {
          _isResendEnabled = true;
          _timer?.cancel();
        });
      } else {
        setState(() {
          _timerDuration--;
        });
      }
    });
  }

  Future<void> _generateOTP() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final token = userModel.token;
      final data = {'email': _newEmailController.text};
      setState(() {
        _isGeneratingOTP = true;
        _timerDuration = 30;
      });
      try {
        final message = await ProfileService.changeEmail(token, data);
        setState(() {
          _isOTPSent = true;

        });
        _showErrorModal(context, '$message');
        _startTimer();
    
      } catch (e) {
        setState(() {
        _showErrorModal(context,'$e');
      });
      } finally {
        setState(() {
          _isGeneratingOTP = false;
        });
      }
    }
  }

  Future<void> _verifyOTP() async {
    final token = userModel.token;
    final data = {'email': _newEmailController.text, 'otp': _otpController.text};
    setState(() {
      _isVerifyingOTP = true;
    });
    try {
      final message = await ProfileService.changeEmailOTP(token, data);
      setState(() {
        _currentEmailController.text = _newEmailController.text;
        _newEmailController.clear();
        _otpController.clear();
        _isOTPSent = false;
      });
       _showErrorModal(context,'$message');
    
    } catch (e) {
        setState(() {
       _showErrorModal(context,'$e');
      });
    } finally {
      setState(() {
        _isVerifyingOTP = false;
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
  @override
Widget build(BuildContext context) {
  double sidebarWidth = 20.0;
  bool displaySidebar = true; 
  double screenWidth = MediaQuery.of(context).size.width;
  double marginLeft = displaySidebar ? (screenWidth > 991 ? sidebarWidth : 0.0) : 0.0;

  return Scaffold(
    body: Stack(
      children: [
        Container(
          margin: EdgeInsets.only(left: marginLeft),
          padding: EdgeInsets.only(bottom: 32.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Container(
                        width: screenWidth > 600 ? 600 : screenWidth * 0.9,
                        child: Form(
                          key: _formKey,
                          child: Card(
                            color: Colors.white, 
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: <Widget>[
                                  Center(
                                    child: Text(
                                      'Change Your Email',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  _buildTextField(
                                    label: 'Current Email',
                                    controller: _currentEmailController,
                                    readOnly: true,
                                  ),
                                  SizedBox(height: 20),
                                  _buildTextField(
                                    label: 'New Email',
                                    controller: _newEmailController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a new email';
                                      }
                                      return null;
                                    },
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
                                            onPressed: _isResendEnabled ? _generateOTP : null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(0xFF313256),
                                              foregroundColor: Colors.white,
                                              minimumSize: Size(100, 50),
                                            ),
                                            child: Text(
                                              _isResendEnabled
                                                  ? 'Resend OTP'
                                                  : 'Resend in $_timerDuration s',
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: _isVerifyingOTP ? null : _verifyOTP,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF313256),
                                          foregroundColor: Colors.white,
                                          minimumSize: Size(double.infinity, 50),
                                        ),
                                        child: _isVerifyingOTP
                                            ? CircularProgressIndicator(color: Colors.white)
                                            : Text('Verify OTP'),
                                      ),
                                    ] 
                                    else ...[
                                    SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: _isGeneratingOTP ? null : _generateOTP,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF313256),
                                        foregroundColor: Colors.white,
                                        minimumSize: Size(double.infinity, 50),
                                      ),
                                      child: _isGeneratingOTP ? CircularProgressIndicator(color: Colors.white) : Text('Generate OTP'),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    FormFieldValidator<String?>? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: validator,
        readOnly: readOnly,
      ),
    );
  }
}
