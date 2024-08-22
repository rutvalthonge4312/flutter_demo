import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wrms.app/routes.dart';
import 'package:wrms.app/models/index.dart';
import 'package:wrms.app/screens/onboarding/widgets/leave_management_form.dart';
import 'package:wrms.app/services/profile_service.dart';
import 'package:wrms.app/types/request_profile.dart';
// import 'package:wrms.app/models/error_model.dart';
import 'package:wrms.app/services/auth_service.dart';
// import 'package:wrms.app/models/auth_model.dart';

class EditProfileForm extends StatefulWidget {
  final UserModel userModel;
  const EditProfileForm({Key? key, required this.userModel}) : super(key: key);
  
  @override
  _EditProfileFormState createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  late UserModel userModel;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _postsController;
  late TextEditingController _roleController;
  late TextEditingController _stationController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _emailController;


  bool _isLoadingProfile = false;
  bool _isUpdatingProfile = false;
  bool _isLoadingChangeEmail = false;
  bool _isLoadingChangePassword = false;
  bool _isLoadingChangeMobile = false;
  bool _showErrorModal = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    userModel = Provider.of<UserModel>(context, listen: false); 
    _firstNameController = TextEditingController();
    _middleNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _postsController = TextEditingController();
    _roleController=TextEditingController();
    _stationController=TextEditingController();
    _phoneNumberController=TextEditingController();
    _emailController=TextEditingController();
    _getProfile();
  }


  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _postsController.dispose();
    _roleController.dispose();
    _stationController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _getProfile() async {
    setState(() {
      _isLoadingProfile = true;
    });
    try {
      final token = userModel.token;
      final profileResponse = await ProfileService.getProfile(token);
      setState(() {
        print(profileResponse.user?.phone);
        _firstNameController.text = profileResponse.user?.firstName ?? '';
        _middleNameController.text = profileResponse.user?.middleName ?? '';
        _lastNameController.text = profileResponse.user?.lastName ?? '';
        _postsController.text = profileResponse.posts?.join(', ') ?? '';
        _roleController.text= profileResponse.role ?? '';
        _stationController.text=profileResponse.station ?? '';
        _phoneNumberController.text = profileResponse.user?.phone ?? '';
        _emailController.text = profileResponse.user?.email ?? '';



      });
    } catch (e) {
      setState(() {
        _showErrorModal = true;
        _errorMessage = '$e';
      });
    } finally {
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isUpdatingProfile = true;
      });
      try {
        final token = userModel.token;
        final updatedProfile = RequestProfile(
          firstName: _firstNameController.text,
          middleName: _middleNameController.text,
          lastName: _lastNameController.text,
          posts: _postsController.text.split(RegExp(r'\s+|,\s*|\s*,')).map((post) => post.toUpperCase()).toList(),
        );
        final message = await ProfileService.updateProfile(token, updatedProfile);
        setState(() {
          _showErrorModal = true;
          _errorMessage = message;
        });
      } catch (e) {
        setState(() {
          _showErrorModal = true;
          _errorMessage = '$e';
        });
      } finally {
        setState(() {
          _isUpdatingProfile = false;
        });
      }
    }
  }
  
  Future<void> _changeEmail() async {
    setState(() {
      _isLoadingChangeEmail = true;
    });
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate delay
      Navigator.pushNamed(context, '/change_mail');
    } catch (e) {
      setState(() {
        _showErrorModal = true;
        _errorMessage = '$e';
      });
    } finally {
      setState(() {
        _isLoadingChangeEmail = false;
      });
    }
  }

  Future<void> _changePassword() async {
    setState(() {
      _isLoadingChangePassword = true;
    });
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate delay
      Navigator.pushNamed(context, '/change_password');
    } catch (e) {
      setState(() {
        _showErrorModal = true;
        _errorMessage = '$e';
      });
    } finally {
      setState(() {
        _isLoadingChangePassword = false;
      });
    }
  }

  Future<void> _changeMobile() async {
    setState(() {
      _isLoadingChangeMobile = true;
    });
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate delay
      Navigator.pushNamed(context, '/change_mobile');
    } catch (e) {
      setState(() {
        _showErrorModal = true;
        _errorMessage = '$e';
      });
    } finally {
      setState(() {
        _isLoadingChangeMobile = false;
      });
    }
  }

  Future<void> _deactivateAccount() async {
    final bool confirmDeactivation = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:const Text('Confirm Deactivation'),
          content:const Text('Are you sure you want to deactivate your account?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); 
              },
              child:const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true); 
                try {
                  final authModel = Provider.of<AuthModel>(context, listen: false);
                  final token = authModel.loginResponse!.token; // Adjust to your token retrieval logic
                  await AuthService.deactivateAccount(token);
                  authModel.logout();
                  Navigator.pushReplacementNamed(context, Routes.login);
                } catch (e) {
                  setState(() {
                    _showErrorModal = true;
                    _errorMessage = '$e';
                  });
                }
              },
              child:const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmDeactivation == true) {
      Navigator.pop(context); // Close the dialog if needed
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, FormFieldSetter<String?> onSaved, String? Function(String?)? validator,bool isDisabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: isDisabled,
        decoration: InputDecoration(
          labelText: label,
          border:const OutlineInputBorder(),
        ),
        onSaved: onSaved,
        validator: validator,
      ),
    );
  }

  Widget _buildButton(String label, bool isLoading, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF313256),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          minimumSize: const Size(double.infinity, 50),
        ),
        child: isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(label),
      ),
    );
  }

  Widget _buildProfileForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildTextField('First Name', _firstNameController, (value) => _firstNameController.text = value!,
              (value) {
            if (value == null || value.isEmpty) {
              return 'First Name is required';
            }
            if (value.length < 3) {
              return 'First Name must be at least three characters!';
            }
            if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
              return 'First Name can only contain alphabets!';
            }
            return null;
          },false,),
          _buildTextField('Middle Name', _middleNameController, (value) => _middleNameController.text = value!, (value) {
            if (value != null && value.isNotEmpty && !RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
              return 'Middle Name can only contain alphabets!';
            }
            return null;
          },false,),
          _buildTextField('Last Name', _lastNameController, (value) => _lastNameController.text = value!,
              (value) {
            if (value == null || value.isEmpty) {
              return 'Last Name is required';
            }
            if (value.length < 3) {
              return 'Last Name must be at least three characters!';
            }
            if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
              return 'Last Name can only contain alphabets!';
            }
            return null;
          },false,),
          _buildTextField('Station', _stationController, (value) => _stationController.text = value!,
              (value) {
            return null;
          },true,),
          _buildTextField('Role', _roleController, (value) => _roleController.text = value!,
              (value) {
           
            return null;
          },true,),
          // _buildTextField('Post Assigned', _postsController, (value) => _postsController.text = value!,
          //     (value) {
            
          //   return null;
          // },true,),

          _buildTextField('Phone Number', _phoneNumberController, (value) => _phoneNumberController.text = value!,
              (value) {
            
            return null;
          },true,),
          _buildTextField('Email', _emailController, (value) => _emailController.text = value!,
              (value) {
            
            return null;
          },true,),
          
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isUpdatingProfile ? null : _updateProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF313256),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(double.infinity,              50),
            ),
            child: _isUpdatingProfile ? const CircularProgressIndicator(color: Colors.white) : const Text('Update Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonsColumn(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildButton("Change Email", _isLoadingChangeEmail, _changeEmail),
        _buildButton("Change Password", _isLoadingChangePassword, _changePassword),
        _buildButton("Change Mobile Number", _isLoadingChangeMobile, _changeMobile),
        const SizedBox(height: 20),
         ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, Routes.leaveManagement);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF313256),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('Leave Management'),
        ),
        const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _deactivateAccount,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(197, 177, 13, 1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Deactivate Account'),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double padding = 16.0;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: screenWidth > 600
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Left side: Form Card
                      Expanded(
                        child: Card(
                          color: Colors.white,
                          child: Padding(
                            padding: EdgeInsets.all(padding),
                            child: _isLoadingProfile
                                ? const Center(child: CircularProgressIndicator())
                                : _buildProfileForm(),
                          ),
                        ),
                      ),
                      SizedBox(width: padding),
                      // Right side: Buttons Card
                      Expanded(
                        child: Card(
                          color: Colors.white,
                          child: Padding(
                            padding: EdgeInsets.all(padding),
                            child: _buildButtonsColumn(context),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: <Widget>[
                      // Form Card
                      Card(
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(padding),
                          child: _isLoadingProfile
                              ? const Center(child: CircularProgressIndicator())
                              : _buildProfileForm(),
                        ),
                      ),
                      SizedBox(height: padding),
                      // Buttons Card
                      Card(
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(padding),
                          child: _buildButtonsColumn(context),
                        ),
                      ),
                    ],
                  ),
          ),
          if (_showErrorModal)
            Center(
              child: ErrorModal(
                message: _errorMessage,
                onClose: () {
                  setState(() {
                    _showErrorModal = false;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}