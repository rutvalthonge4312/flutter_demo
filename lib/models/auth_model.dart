import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:wrms.app/types/index.dart';

class AuthModel extends ChangeNotifier {
  bool _isAuthenticated = false;
  LoginResponse? _loginResponse;

  bool get isAuthenticated => _isAuthenticated;
  LoginResponse? get loginResponse => _loginResponse;

  AuthModel() {
    loadAuthState();
  }

  Future<void> login(LoginResponse loginResponse) async {
    _isAuthenticated = true;
    _loginResponse = loginResponse;
    notifyListeners();
    await _saveAuthState();
  }
  Future<void> signup() async {
    _isAuthenticated = false;
    _loginResponse = null;
    notifyListeners();
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _loginResponse = null;
    notifyListeners();
    await _clearAuthState();
  }

  Future<void> _saveAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isAuthenticated', _isAuthenticated);
    if (_loginResponse != null) {
      prefs.setString('loginResponse', jsonEncode(_loginResponse!.toJson()));
    }
  }

  Future<void> loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    if (_isAuthenticated) {
      final loginResponseJson = prefs.getString('loginResponse');
      if (loginResponseJson != null) {
        _loginResponse = LoginResponse.forState(jsonDecode(loginResponseJson));
      } 
    }
    notifyListeners();
  }

  Future<void> _clearAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('isAuthenticated');
    prefs.remove('loginResponse');
    prefs.remove('lastRoute');
  }
}
