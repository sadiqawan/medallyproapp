import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../auth/login_screen.dart';
import '../constants/mycolors.dart';
import '../providers/splash_screen_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  bool _mounted = false;

  @override
  void initState() {
    super.initState();
    _mounted = true;
    Timer(const Duration(seconds: 5), () {
      if (_mounted) {
        Provider.of<SplashScreenProvider>(context, listen: false)
            .hideProgressIndicator();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      }
    });
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Consumer<SplashScreenProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              SizedBox(
                height: height,
                width: width,
                child: Image.asset(
                  "assets/images/splashbackground.png",
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
                ),
              ),
              Container(
                height: 500.0,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: const Text(
                  'Medallypro',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30.0,
                    color: textColor,
                    letterSpacing: 0.7,
                    fontFamily: 'GT Walsheim Trial',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Conditional rendering of the progress indicator
              if (provider.showProgressIndicator)
                const Padding(
                  padding: EdgeInsets.only(top: 550.0),
                  child: Center(
                    child: SpinKitCircle(
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
