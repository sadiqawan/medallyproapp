import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../auth/otp_screen.dart';

class OtpNotifier with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isRegistering = false;
  bool get isRegistering => _isRegistering;

  set isRegistering(bool value) {
    _isRegistering = value;
    print("Registering $_isRegistering");
    notifyListeners();
  }

  User? _user;
  User? get user => _user;

  String _verificationid = "";
  int? _resendtoken;

  Future<void> signInWithPhoneNumber(String? phoneNumber, context) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            print('The provided phone number is not valid.');
          }
          // Handle other verification failures here
          // Set isRegistering to false to stop the circular progress indicator
          isRegistering = false;
          Fluttertoast.showToast(msg: "Failed to verify phone number");
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationid = verificationId;
          _resendtoken = resendToken;
          if (kDebugMode) {
            print("Code Sent: $verificationId");
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(verificationId: verificationId, phoneNumber: phoneNumber,),
            ),
          );
        },
        timeout: const Duration(seconds: 25),
        forceResendingToken: _resendtoken,
        codeAutoRetrievalTimeout: (String verificationId) {
          verificationId = _verificationid;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      // Handle other exceptions here
      // Set isRegistering to false to stop the circular progress indicator
      isRegistering = false;
      Fluttertoast.showToast(msg: "Failed to initiate phone verification");    }
  }

}

