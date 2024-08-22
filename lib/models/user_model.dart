import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:wrms.app/types/index.dart';

class UserModel extends ChangeNotifier {
  String _userName = '';
  String _mobileNumber = '';
  int _stationCode = 0;
  String _stationName = '';
  String _email = '';
  String _token = '';
  String _userType = '';
  String _refreshToken = '';
  LoginResponse? _loginResponse;

  String get userName => _userName;
  String get mobileNumber => _mobileNumber;
  int get stationCode => _stationCode;
  String get stationName => _stationName;
  String get email => _email;
  String get token => _token;
  String get refreshToken => _refreshToken;
  String get userType => _userType;

  UserModel() {
    loadUserData();
  }

  Future<void> updateUserDetails({
    String? userName,
    String? email,
    String? mobileNumber,
    int? stationCode,
    String? stationName,
    String? token,
    String? userType,
    String? refreshToken,
  }) async {
    _userName = userName ?? _userName;
    _email = email ?? _email;
    _mobileNumber = mobileNumber ?? _mobileNumber;
    _stationCode = stationCode ?? _stationCode;
    _stationName = stationName ?? _stationName;
    _token = token ?? _token;
    _userType = userType ?? _userType;
    _refreshToken = refreshToken ?? _refreshToken;
    notifyListeners();
    await _saveUserData();
  }

  Future<void> updateStationDetails({
    int? stationCode,
    String? stationName,
  }) async {
   
    _stationCode = stationCode ?? _stationCode;
    _stationName = stationName ?? _stationName;
    notifyListeners();
    await _saveUserData();
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = {
      'userName': _userName,
      'mobileNumber': _mobileNumber,
      'stationCode': _stationCode,
      'stationName': _stationName,
      'email': _email,
      'token': _token,
      'userType': _userType,
      'refreshToken': _refreshToken,
      'loginResponse': _loginResponse?.toJson(),
    };

    await prefs.setString('loginResponse', jsonEncode(userData));
  }

  String get trimmedUserName {
    return userName.length > 11
        ? userName.substring(0, userName.length - 11)
        : userName;
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final loginResponseJson = prefs.getString('loginResponse');
    _loginResponse = LoginResponse.forState(jsonDecode(loginResponseJson!));
    _userName = _loginResponse!.userName;
    _token = _loginResponse!.token;
    _mobileNumber = _loginResponse!.mobileNumber;
    _stationCode = _loginResponse!.stationCode;
    _stationName = _loginResponse!.stationName;
    _userType = _loginResponse!.userType;
    _refreshToken = _loginResponse!.refreshToken;
    notifyListeners();
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('loginResponse');
    _userName = '';
    _mobileNumber = '';
    _stationCode = 0;
    _stationName = '';
    _email = '';
    _token = '';
    _userType = '';
    _refreshToken = '';
    notifyListeners();
  }
}
