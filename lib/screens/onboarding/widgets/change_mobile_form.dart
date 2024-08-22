import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wrms.app/models/index.dart';
import 'package:wrms.app/services/profile_service.dart';

class ChangeMobile extends StatefulWidget {
  final UserModel userModel;
  const ChangeMobile({Key? key, required this.userModel}) : super(key: key);
  @override
  _ChangeMobileState createState() => _ChangeMobileState();
}

class _ChangeMobileState extends State<ChangeMobile> {
  late UserModel userModel;
  late TextEditingController _newPhoneController;
  late TextEditingController _otpController;
  TextEditingController _currentMobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isOTPSent = false;
  bool _isLoading = false; 
  bool _verifyingOTP = false; 
    bool _showResendButton = false;
  String? _currentMobile;
  bool _showModal = false;
  Timer? _timer;
  int _timerSeconds = 30;

  @override
  void initState() {
    super.initState();
    userModel = Provider.of<UserModel>(context, listen: false);
    _newPhoneController = TextEditingController();
    _otpController = TextEditingController();
    _getProfile();
  }

  @override
  void dispose() {
    _newPhoneController.dispose();
    _otpController.dispose();
    _currentMobileController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _getProfile() async {
    try {
      final token = userModel.token;
      final profileResponse = await ProfileService.getProfile(token);
      setState(() {
        _currentMobile = profileResponse.user?.phone;
        _currentMobileController.text = _currentMobile ?? '';
      });
    } catch (e) {
        setState(() {
        _showErrorModal(context,'$e');
      });
    }
  }

  Future<void> _handlePhoneOtp() async {
    if (_newPhoneController.text.isEmpty) {
      
      setState(() {
        _showErrorModal(context,'Please enter a valid mobile number');
      });
      return;
    }
    setState(() {
      _isLoading = true; 
    });
    final token = userModel.token;
    final data = {'phone': _newPhoneController.text};
    try {
      final message = await ProfileService.changePhone(token, data);
      setState(() {
        _isOTPSent = true;
        _startTimer();
      });
       _showErrorModal(context,'$message');
    } catch (e) {
     setState(() {
       _showErrorModal(context,'$e');
      });
    } finally {
      setState(() {
        _isLoading = false; // Reset loading state regardless of success or failure
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
    await _handlePhoneOtp();
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
    final data = {'phone': _newPhoneController.text, 'otp': _otpController.text};
    try {
      final message = await ProfileService.confirmChangePhone(token, data);
      _showErrorModal(context, '$message');
      if (message.contains('success')) {
        await _getProfile();
        Navigator.of(context).pop(); 
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ChangeMobile(userModel: widget.userModel),
          ),
        );
      }
    } catch (e) {
       _showErrorModal(context,'$e');
      
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
                                        'Change Your Mobile Number',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    _buildTextField(
                                      label: 'Current Mobile Number',
                                      controller: _currentMobileController,
                                      readOnly: true,
                                    ),
                                    SizedBox(height: 20),
                                    _buildTextField(
                                      label: 'New Mobile Number',
                                      controller: _newPhoneController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a new mobile number';
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
                                        onPressed: _isLoading ? null : _handlePhoneOtp,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF313256),
                                          foregroundColor: Colors.white,
                                          minimumSize: Size(double.infinity, 50),
                                        ),
                                        child: _isLoading
                                            ? CircularProgressIndicator(color: Colors.white)
                                            : Text('Generate OTP'),
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
        readOnly: readOnly,
        validator: validator,
      ),
    );
  }
  