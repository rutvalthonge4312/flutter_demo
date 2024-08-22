import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:wrms.app/models/auth_model.dart';
import 'package:wrms.app/routes.dart';
import 'package:wrms.app/services/index.dart';
import 'package:provider/provider.dart';
import 'package:wrms.app/services/otp_service.dart';
import 'package:wrms.app/models/error_model.dart';
import 'dart:async'; 

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  _SignupForm createState() => _SignupForm();
}

class _SignupForm extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  String? _mobileNumber;
  String? _password;
  String? _selectedRole;
  String? _selectedStation;
  String? fName;
  String? mName;
  String? lName;
  String? email;
  String? phone;
  String? password;
  String? rePassword;
  String? userType;
  String? station;
  String? post = 'No Post Assigned';
  bool _obscureText = true;
  bool _obscureText2 = true;
  bool _showMobileOtp = false;
  bool _showEmailOtp = false;
  bool _mobileVerified = false;
  bool _emailVerified = false;
  String? value;
  String? otp;
  String? type;
  bool _isLoading = false;
  bool _isMobileOtpSend = false;
  bool _isEmailOtpSend = false;
  bool _isMobileOtpVerify = false;
  bool _isEmailOtpVerify = false;
  final List<String> _roles = [
    'supervisor',
    'contractor',
    'station manager',
    'railway admin',
    'officer',
  ];
  final List<Map<String, dynamic>> _stations = [
    {
      'stationCode': '100',
      'stationName': 'PNBE',
    },
    {
      'stationCode': '102',
      'stationName': 'PPTA',
    },
  ];
  bool _showModal = false;
  Timer? _emailTimer;
  int _emailTimerDuration = 30; 
  int _emailTimeLeft = 30; 
  bool _canResendEmailOtp = false;
  Timer? _mobileTimer;
  int _mobileTimerDuration = 30; 
  int _mobileTimeLeft = 30; 
  bool _canResendMobileOtp = false;

  void initState() {
    super.initState();
  }

  void _startEmailTimer() {
    _emailTimeLeft = _emailTimerDuration;
    _canResendEmailOtp = false;
    _emailTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_emailTimeLeft > 0) {
          _emailTimeLeft--;
        } else {
          _canResendEmailOtp = true;
          timer.cancel();
        }
      });
    });
  }

    void _startMobileTimer() {
    _mobileTimeLeft = _mobileTimerDuration;
    _canResendMobileOtp = false;
    _mobileTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_mobileTimeLeft > 0) {
          _mobileTimeLeft--;
        } else {
          _canResendMobileOtp = true;
          timer.cancel();
        }
      });
    });
  }

  void _submitForm() async {
    setState(() {
      _isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        String middleName = mName?.isNotEmpty == true ? mName! : '';

        final signupResponse = await AuthService.signup(
            _mobileNumber!,
            fName!,
            middleName,
            lName!,
            email!,
            _password!,
            rePassword!,
            _selectedRole!,
            _selectedStation!,
            post!);
        Provider.of<AuthModel>(context, listen: false).signup();
        Navigator.pushReplacementNamed(context, Routes.login);
      } catch (e) {
        if (e is StateError && e.toString().contains('mounted')) {
          print('Widget disposed before operation completes');
        } else {
          print('Sign Up Page Error: $e');
        }
      }
    }
    setState(() {
      _isLoading = false;
    });
  }
  
  void _sendOtp({required String type, bool hideShow = true}) async {
    type = type;
    if (type == 'phone') {
      value = _mobileNumber;
      setState(() {
        _isMobileOtpSend=true;
      });
      _startMobileTimer();
    } else {
      value = email;
      setState(() {
        _isEmailOtpSend=true;
      });
       _startEmailTimer(); 
    }
    try {
      final sendOtpResponse = await OtpService.sendOtp(value!, type);
      setState(() {
       _showErrorModal(context,'$sendOtpResponse');
      });
      if (type == 'phone') {
        if (hideShow) {
          setState(() {
            _showMobileOtp = !_showMobileOtp;
            _isMobileOtpSend=false;
          });
        }
      } else {
        if (hideShow) {
          setState(() {
            _showEmailOtp = !_showEmailOtp;
            _isEmailOtpSend=false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _showErrorModal(context,'Send Otp Failed : $e') ;
        _isEmailOtpSend=false;
        _isMobileOtpSend=false;
      });
      if (e is StateError && e.toString().contains('mounted')) {
        print('Widget disposed before operation completes');
      } else {
        print('Send Otp Failed : $e');
      }
    }
    
  }

  void dispose() {
    _emailTimer?.cancel(); 
    _mobileTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void _verifyData(String type) async {
    type = type;
    otp = otp;
    if (type == 'phone') {
      value = _mobileNumber;
      setState(() {
        _isMobileOtpVerify=true;
      });
    } else {
      value = email;
      setState(() {
        _isEmailOtpVerify=true;
      });
    }
    try {
      final verifyOtpResponse = await OtpService.veirfyOtp(value!, otp!, type);
       setState(() {
        _showErrorModal(context,'$verifyOtpResponse');
      });
      if (verifyOtpResponse == 'Error Occourd At Verify Otp') {
        return;
      }
      if (type == 'phone') {
        setState(() {
          _mobileVerified = !_mobileVerified;
          _showMobileOtp = false;
          _isMobileOtpVerify=false;
        });
      } else {
        setState(() {
          _emailVerified = !_emailVerified;
          //_showEmailOtp = !_showEmailOtp;
          _isEmailOtpVerify=false;
          _showEmailOtp = false;
        });
      }
    } catch (e) {
      setState(() {
        _isEmailOtpVerify=false;
         _isMobileOtpVerify=false;
         _showErrorModal(context,'Verification Failed : $e');
      });
      if (e is StateError && e.toString().contains('mounted')) {
        print('Widget disposed before operation completes');
      } else {
        print('Verification Failed : $e');
      }
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
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonWidth = screenWidth * 0.8;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 16,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
    );

    InputDecoration textFieldDecoration(String label) {
      return InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.grey, 
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.grey, 
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.blue,
            width: 2.0,
          ),
        ),
      );
    }
   return   Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0), 
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    keyboardType: TextInputType.text,
                    decoration: textFieldDecoration('First Name'),
                    onChanged: (String? value) {
                      fName = value!;
                    },
                  ),
                  const SizedBox(height: 16), 
                  TextFormField(
                    keyboardType: TextInputType.text,
                    decoration: textFieldDecoration('Middle Name'),
                    onChanged: (String? value) {
                      mName = value ?? '';
                    },
                  ),
                  const SizedBox(height: 16), 
                  TextFormField(
                    keyboardType: TextInputType.text,
                    decoration: textFieldDecoration('Last Name'),
                    onChanged: (String? value) {
                      lName = value!;
                    },
                  ),
                  const SizedBox(height: 16), 
                  TextFormField(
                    enabled: (_showEmailOtp || !_emailVerified),
                    keyboardType: TextInputType.emailAddress,
                    decoration: textFieldDecoration('Email Address'),
                    onChanged: (String? value) {
                      email = value!;
                    },
                  ),
                  const SizedBox(height: 5),
                  if (!_showEmailOtp && !_emailVerified)
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:const Color(0xFF313256), 
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => _sendOtp(type: 'email'),
                        child: _isEmailOtpSend
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Verify Email'),
                      ),
                    ),
                  if (_emailVerified)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        Icon(Icons.verified, color: Colors.green),
                        SizedBox(width: 5),
                        Text('Verified'),
                      ],
                    ),
                  if (_showEmailOtp)
                    Column(
                      children: [
                        Pinput(
                          length: 6,
                          defaultPinTheme: defaultPinTheme,
                          onChanged: (String? value) {
                            otp = value!;
                          },
                          showCursor: true,
                          onCompleted: (pin) {
                            otp = pin;
                          },
                        ),
                        Align(
                        alignment: Alignment.centerRight,
                        child:
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                          backgroundColor:const Color(0xFF313256), 
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),),
                          onPressed: () => _verifyData('mobile'),
                          child: _isMobileOtpVerify
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text('Verify OTP'),
                        ),
                        ),
                        const SizedBox(height: 16),
                        if (_emailTimeLeft > 0)
                          Text('Resend OTP visible in $_emailTimeLeft seconds'),
                        if (_canResendEmailOtp)
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:const Color(0xFF313256), 
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                            onPressed: () {
                              _sendOtp(type: 'email', hideShow: false);
                            },
                            child: const Text('Resend Email OTP'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                    enabled: !_mobileVerified,
                    keyboardType: TextInputType.phone,
                    decoration: textFieldDecoration('Mobile Number'),
                    onChanged: (String? value) {
                      _mobileNumber = value!;
                    },
                  ),
                  const SizedBox(height: 5),
                  if (!_showMobileOtp && !_mobileVerified)
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:const Color(0xFF313256), 
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => _sendOtp(type: 'phone'),
                        child: _isMobileOtpSend
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Verify Mobile'),
                      ),
                    ),
                  if (_mobileVerified)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        Icon(Icons.verified, color: Colors.green),
                        SizedBox(width: 5),
                        Text('Verified'),
                      ],
                    ),
                  if (_showMobileOtp)
                    Column(
                      children: [
                        Pinput(
                          length: 6,
                          defaultPinTheme: defaultPinTheme,
                          onChanged: (String? value) {
                            otp = value!;
                          },
                          showCursor: true,
                          onCompleted: (pin) {
                            otp = pin;
                          },
                        ),
                        Align(
                        alignment: Alignment.centerRight,
                        child:
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                          backgroundColor:const Color(0xFF313256), 
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),),
                          onPressed: () => _verifyData('phone'),
                          child: _isMobileOtpVerify
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text('Verify OTP'),
                        ),
                        ),
                        const SizedBox(height: 16),
                        if (_mobileTimeLeft > 0)
                          Text('Resend OTP visible in $_mobileTimeLeft seconds'),
                        if (_canResendMobileOtp)
                        Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:const Color(0xFF313256), 
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => _sendOtp(type: 'phone',hideShow: false),
                          child: const Text('Resend Mobile OTP'),
                        ),
                      ),
                      ],
                    ),

                  const SizedBox(height: 16), 
                  TextFormField(
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.grey, 
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.grey, 
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.blue, 
                          width: 2.0, 
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                    onChanged: (String? value) {
                      _password = value!;
                    },
                  ),
                  const SizedBox(height: 16), 
                  TextFormField(
                    obscureText: _obscureText2,
                    decoration: InputDecoration(
                      labelText: 'Re-enter Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.grey, 
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.grey, 
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.blue, 
                          width: 2.0, 
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText2 ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText2 = !_obscureText2;
                          });
                        },
                      ),
                    ),
                    onChanged: (String? value) {
                      rePassword = value!;
                    },
                  ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: textFieldDecoration('Select Role'),
                  // Reuse textFieldDecoration
                  value: _selectedRole,
                  items: _roles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a role';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _selectedRole = value;
                  },
                ),
                const SizedBox(height: 16), // Add spacing between fields
                DropdownButtonFormField<String>(
                  decoration: textFieldDecoration('Select Station'),
                  // Reuse textFieldDecoration
                  value: _selectedStation,
                  items: _stations.map((station) {
                    return DropdownMenuItem<String>(
                      value: station['stationCode'],
                      child: Text(station['stationName'] as String),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStation = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a station';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _selectedStation = value;
                  },
                ),
                const SizedBox(height: 16), // Add spacing between fields
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:const Color(0xFF313256), // background // background
                    foregroundColor: Colors.white,
                    fixedSize: Size(buttonWidth, 50),
                  ),
                  onPressed:
                  (_mobileVerified && _emailVerified) ? _submitForm : null,
                  child: _isLoading
                      ?const CircularProgressIndicator(color: Colors.white)
                      : const Text('Request For Sign Up'),
                ),
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/');
                    },
                    child:const Text(
                      'Already have an account',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 2, 137, 247),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                ],
              ),
            ),
          ),
        ),
      ],
    // )
   );
   
  }
}