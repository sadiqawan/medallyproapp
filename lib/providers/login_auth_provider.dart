import 'package:flutter/material.dart';
import 'package:medallyproapp/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthNotifier with ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isRegistered = false;

  bool get isLoggedIn => _isLoggedIn;
  bool get isRegistered => _isRegistered;

  registeredUserStatus() async{
    await Future.delayed(const Duration(seconds: 1));
    _isRegistered = true;
    notifyListeners();
  }


  Future<void> login() async {
    await Future.delayed(const Duration(seconds: 1));
    _isLoggedIn = true;
    await _saveLoginState(true);
    notifyListeners();
  }

  logout(context) async {
    await Future.delayed(const Duration(seconds: 1));
    _isLoggedIn = false;
    await _saveLoginState(false);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen(),),);
    notifyListeners();
  }

  Future<void> _saveLoginState(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', isLoggedIn);
  }

  Future<void> _loadLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    notifyListeners();
  }

  Future<void> initialize() async {
    await _loadLoginState();
  }
}





