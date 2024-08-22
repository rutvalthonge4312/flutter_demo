import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:wrms.app/models/index.dart';
import 'package:wrms.app/routes.dart';
import 'package:wrms.app/services/auth_service.dart';
import 'package:intl/intl.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({Key? key, required this.title}) : super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize {
    double height = kToolbarHeight; 
    // ignore: deprecated_member_use
    if (MediaQueryData.fromView(WidgetsBinding.instance.window).size.width < 600) {
      height = kToolbarHeight + 10; 
    }
    return Size.fromHeight(height);
  }
}

class _CustomAppBarState extends State<CustomAppBar> {
  String? _videoUploadCount;
  bool _isVideoUploading = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _fetchVideoUploadDetails();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      _fetchVideoUploadDetails();
    });
  }

  Future<void> _fetchVideoUploadDetails() async {
    final prefs = await SharedPreferences.getInstance();
    bool isVideoUploading = prefs.getBool('isVideoUpload') ?? false;
    int videoUploadCount = prefs.getInt('videoUploadCount') ?? 0;

    setState(() {
      _isVideoUploading = isVideoUploading;
      _videoUploadCount = videoUploadCount.toString();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue,
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
      title: Consumer<UserModel>(
        builder: (context, userModel, child) {
          final roleLetter = _getRoleLetter(userModel.userType);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    return GestureDetector(
                      onTap: (){
                        Navigator.pushNamed(context, Routes.home);
                      },
                    child: const Text(
                      'WRMS',
                      style:  TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                    );
                  } else {
                    return GestureDetector(
                      onTap: (){
                        Navigator.pushNamed(context, Routes.home);
                      },
                    child:  const Text(
                      'WRMS (Water Refilling Management System)',
                      style:  TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                    );
                  }
              
                },
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '[ ${userModel.stationName} ]',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          userModel.userName.length > 11
                              ? userModel.userName.substring(0, userModel.userName.length - 11)
                              : userModel.userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                        if (roleLetter.isNotEmpty) ...[
                          const SizedBox(width: 5),
                          Text(
                            '[$roleLetter]',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                        const SizedBox(width: 5),
                        Text(
                          '[${DateFormat('dd MMM yyyy').format(DateTime.now())}]',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Container(); 
                  }
                },
              ),
              const SizedBox(height: 2),
              if (_isVideoUploading) ...[
                Text(
                  'Uploading: $_videoUploadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ],
          );
        },
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 30.0), // Adjust this value to move the icon more to the left
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            offset: const Offset(0, kToolbarHeight),
            onSelected: (String result) async {
              if (result == 'Profile') {
                Navigator.of(context).pushNamed('/edit_profile');
                // showDialog(
                //   context: context,
                //   builder: (BuildContext context) {
                //     return AlertDialog(
                //       title: const Text('Profile'),
                //       content: Consumer<UserModel>(
                //         builder: (context, userModel, child) {
                //           return Text('Username: ${userModel.userName}');
                //         },
                //       ),
                //       actions: [
                //         TextButton(
                //           onPressed: () {
                //             Navigator.of(context).pop();
                //           },
                //           child: const Text('Close'),
                //         ),
                //         TextButton(
                //           onPressed: () {
                //             Navigator.of(context).pushNamed('/edit_profile');
                //           },
                //           child: const Text('Edit Profile'),
                //         ),
                //       ],
                //     );
                //   },
                // );
              } else if (result == 'Logout') {
                final authModel = Provider.of<AuthModel>(context, listen: false);
                try {
                  await AuthService.logout(
                    authModel.loginResponse!.refreshToken,
                    authModel.loginResponse!.token,
                  );
                  authModel.logout();
                  Navigator.pushReplacementNamed(context, Routes.login);
                } catch (e) {
                  authModel.logout();
                  Navigator.pushReplacementNamed(context, Routes.login);
                }
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Profile', 'Logout'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Row(
                    children: [
                      if (choice == 'Profile') const Icon(Icons.person),
                      if (choice == 'Logout') const Icon(Icons.logout),
                      const SizedBox(width: 10),
                      Text(choice),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ),
      ],
    );
  }

  String _getRoleLetter(String userType) {
    switch (userType) {
      case 'railway admin':
        return 'A';
      case 'railway manager':
        return 'M';
      case 'chi_sm':
        return 'S';
      case 's2 admin':
        return 's2A';
      default:
        return userType.isNotEmpty ? userType[0].toUpperCase() : ''; // First letter in uppercase for other user types
    }
  }
}
