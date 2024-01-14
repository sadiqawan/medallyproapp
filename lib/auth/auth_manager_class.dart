import 'package:medallyproapp/sharedpreference/share_preference.dart';

class AuthManager {
  static const String isLoggedInKey = 'isLoggedIn';

  static Future<bool> isLoggedIn() async {
    return MySharedPrefClass.preferences?.getBool(isLoggedInKey) ?? false;
  }

  static Future<void> setLoggedIn(bool value) async {
    await MySharedPrefClass.preferences?.setBool(isLoggedInKey, value);
  }
}
