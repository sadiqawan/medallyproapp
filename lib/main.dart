import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:medallyproapp/auth/auth_manager_class.dart';
import 'package:medallyproapp/constants/mycolors.dart';
import 'package:medallyproapp/notifications/notification_service.dart';
import 'package:medallyproapp/providers/member_provider_addprescription.dart';
import 'package:medallyproapp/providers/otp_provider.dart';
import 'package:medallyproapp/providers/register_provider.dart';
import 'package:medallyproapp/providers/splash_screen_provider.dart';
import 'package:medallyproapp/providers/time_provider.dart';
import 'package:medallyproapp/screens/prescription_list.dart';
import 'package:medallyproapp/screens/splash_screen.dart';
import 'package:medallyproapp/sharedpreference/share_preference.dart';
import 'package:medallyproapp/widgets/handle_permission_denied.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';



// Permission Handler
Future<void> permissionHandler() async {
  PermissionStatus notificationStatus = await Permission.notification.request();
  switch (notificationStatus) {
    case PermissionStatus.granted:
      Fluttertoast.showToast(msg: "Permission Granted.");
      break;
    case PermissionStatus.denied:
      Fluttertoast.showToast(msg: "You Need To Provide Camera Permission.");
      break;
    case PermissionStatus.permanentlyDenied:
      const HandlePermissionDenied();
      break;
    default:
      break;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAXvoukOwG7sb7Mhb0EpWT8vLq7AnWG0XU',
      appId: '1:638150020050:android:6de86880dde450dedc160b',
      messagingSenderId: '638150020050',
      projectId: 'medallypro-860d2',
      storageBucket: 'medallypro-860d2.appspot.com',
    ),
  );
  MySharedPrefClass.preferences = await SharedPreferences.getInstance();
  await permissionHandler();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<RegisterProvider>(create: (context) => RegisterProvider()),
        ChangeNotifierProvider<OtpNotifier>(create: (context) => OtpNotifier()),
        ChangeNotifierProvider<TimeProvider>(create: (context) => TimeProvider()),
        ChangeNotifierProvider<MemberProvider>(create: (context) => MemberProvider()),
        ChangeNotifierProvider<SplashScreenProvider>(create: (context) => SplashScreenProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
      ),
      home: FutureBuilder<bool>(
        future: AuthManager.isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            bool isLoggedIn = snapshot.data ?? false;
            return isLoggedIn ? const PrescriptionListScreen() : const SplashScreen();
          } else {
            return const SplashScreen();
          }
        },
      ),
    );
  }
}



