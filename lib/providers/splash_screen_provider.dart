import 'package:flutter/cupertino.dart';

class SplashScreenProvider with ChangeNotifier{

  bool _showProgressIndicator = true;
  bool get showProgressIndicator => _showProgressIndicator;

  void hideProgressIndicator(){
    _showProgressIndicator = false;
    notifyListeners();
  }
}