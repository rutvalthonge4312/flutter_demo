import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wrms.app/models/index.dart';
import 'package:wrms.app/routes.dart';
import 'package:wrms.app/screens/login/widgets/mobile_number_field.dart';
import 'package:wrms.app/screens/login/widgets/password_field.dart';
import 'package:wrms.app/services/index.dart';
import 'package:wrms.app/widgets/error_modal.dart';
import 'package:wrms.app/widgets/loader_new.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  late String _mobileNumber;
  late String _password;
  bool _isLoading = false;
  bool _isOtpLoginLoading = false;
  final clientId =
      '673131287683-5jjd1052v51h3de340oo2g7ampsbln2b.apps.googleusercontent.com';
  final GoogleSignIn _googleSignIn = GoogleSignIn(
      clientId:
          '673131287683-5jjd1052v51h3de340oo2g7ampsbln2b.apps.googleusercontent.com',
      scopes: [
        'email',
        'https://www.googleapis.com/auth/userinfo.profile',
      ]);
  GoogleSignInAccount? googleUser;

  void _submitForm() async {
    loaderNew(context, "Logging , Please Wait");
    setState(() {
      _isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final loginResponse = await AuthService.login(_mobileNumber, _password);
         Navigator.of(context).pop();
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
         Navigator.of(context).pop();
        if (e is StateError && e.toString().contains('mounted')) {
          print('Widget disposed before operation completes');
        } else {
          showErrorModal(context, '$e', "Error", () {});
        }
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  void googleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? authToken = googleAuth.idToken;
      try {
        final loginResponse = await AuthService.loginWithGoogle(authToken!);
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
          showErrorModal(context, '$e', "Error", () {});
        }
      }
    } catch (error) {
      showErrorModal(context, '$error', "Error", () {});
    }
  }

  void _forgotPass() {
    Navigator.pushReplacementNamed(context, Routes.forgotPassword);
  }
  void _otpLogIn() async {
    setState(() {
      _isOtpLoginLoading = true;
    });
    await Navigator.pushReplacementNamed(context, Routes.mobileLogin);
    setState(() {
      _isOtpLoginLoading = false;
    });
  }

  void _signUp() {
    Navigator.pushReplacementNamed(context, Routes.signUp);
  }

  void maintanceModal(){
    showErrorModal(context, "Feature under development...", "Info", (){});
  }
  Widget renderGoogleSignInButton() {
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonWidth = screenWidth * 0.8;
    return OutlinedButton(
      onPressed: maintanceModal,
      style: OutlinedButton.styleFrom(
        fixedSize: Size(buttonWidth, 50),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/google.png',
            height: 24.0,
          ),
          const SizedBox(width: 8.0),
          const Text('Sign in with Google'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonWidth = screenWidth * 0.8;
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight, // Aligns the image to the right
              child: Image.asset(
                'assets/image.png',
                width: 200.0,
                height: 200.0,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Log In",
              style: TextStyle(
                fontSize: 24.0, // Specify the desired font size
              ),
            ),
            const SizedBox(height: 15),
            MobileNumberField(onSaved: (value) => _mobileNumber = value),
            const SizedBox(height: 5),
            PasswordField(onSaved: (value) => _password = value),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                onPressed: _forgotPass,
                child: const Text('Forgot Password'),
              ),
            ),
            const SizedBox(
              height: 16,
              width: 100,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF313256),
                foregroundColor: Colors.white,
                fixedSize: Size(buttonWidth, 50),
              ),
              onPressed: _submitForm,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Log in'),
            ),
            const SizedBox(height: 25),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 5),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF313256),
                        foregroundColor: Colors.white,
                        fixedSize: Size(buttonWidth, 50),
                        //fixedSize: Size(buttonWidth, 50),
                      ),
                      onPressed: _isOtpLoginLoading ? null : _otpLogIn,
                      child: _isOtpLoginLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Log in with Mobile Number',
                            ),
                    ),
                    const SizedBox(
                      height: 5,
                      width: 5,
                    ),
                    renderGoogleSignInButton(),
                  ],
                ),
                const SizedBox(height: 15),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    fixedSize: Size(buttonWidth, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _signUp,
                  child: const Text('New User? Sign Up Here'),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Privacy Policy",
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            try {
                              const privacyPolicyUrl =
                                  'https://suvidhaen.com/privacypolicy_wrms';
                              final url = Uri.parse(privacyPolicyUrl);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(
                                  url,
                                );
                              }
                            } catch (error) {
                              print(error);
                            }
                          },
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                  width: 20,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Term & Condition",
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            try {
                              const privacyPolicyUrl =
                                  'https://suvidhaen.com/termcondition';
                              final url = Uri.parse(privacyPolicyUrl);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(
                                  url,
                                );
                              }
                            } catch (error) {
                              print(error);
                            }
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
