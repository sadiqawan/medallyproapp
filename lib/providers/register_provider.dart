import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:medallyproapp/sharedpreference/share_preference.dart';
import 'package:medallyproapp/widgets/customtoast_screen.dart';
import '../auth/login_screen.dart';


// class RegisterProvider extends ChangeNotifier {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   bool _isRegistering = false;
//
//   bool get isRegistering => _isRegistering;
//
//   set isRegistering(bool value) {
//     _isRegistering = value;
//     notifyListeners();
//   }
//
//   Future<void> registerUser(String name, String phoneNumber, DateTime dateOfBirth, String gender, context) async {
//     // final authProvider = Provider.of<AuthNotifier>(context, listen: false);
//     try {
//       _isRegistering = true;
//       notifyListeners();
//
//       UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
//         email: '$phoneNumber@example.com',
//         password: 'password',
//       );
//       await userCredential.user!.updateProfile(displayName: name);
//       await _firestore.collection('users').doc(userCredential.user!.uid).set({
//         'name': name,
//         'phoneNumber': phoneNumber,
//         'dateOfBirth': dateOfBirth,
//         'gender': gender,
//         'userId': userCredential.user!.uid
//       });
//
//       // Navigate to login screen after successful registration
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const PrescriptionListScreen(),
//         ),
//       );
//
//       // authProvider.registeredUserStatus();
//     } catch (error) {
//       print("Error registering user: $error");
//     } finally {
//       _isRegistering = false;
//       notifyListeners();
//     }
//   }
// }

class RegisterProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isRegistering = false;

  bool get isRegistering => _isRegistering;

  set isRegistering(bool value) {
    _isRegistering = value;
    notifyListeners();
  }

  Future<bool> isUserRegistered(String phoneNumber) async {
    try {
      // Assuming your users' collection is called 'users'
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (error) {
      print("Error checking user registration: $error");
      return false;
    }
  }

  Future<void> registerUser(String name, String phoneNumber, DateTime dateOfBirth, String gender, context) async {
    try {
      _isRegistering = true;
      notifyListeners();

      // Check if the user is already registered
      bool isUserAlreadyRegistered = await isUserRegistered(phoneNumber);

      if (isUserAlreadyRegistered) {
        print("User with phone number $phoneNumber is already registered");
        CustomToast.showToast(context, "User with phone number $phoneNumber is already registered");
        return;
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: '$phoneNumber@example.com',
        password: 'password',
      );

      await userCredential.user!.updateProfile(displayName: name);
      MySharedPrefClass.preferences?.setString("UserID", userCredential.user!.uid);
      MySharedPrefClass.preferences?.setString("UserName", userCredential.user!.displayName.toString());

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'phoneNumber': phoneNumber,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'userId': userCredential.user!.uid,
      });

      print("object $name");
      MySharedPrefClass.preferences?.setString("myName", name);
      // Navigate to the desired screen after successful registration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    } catch (error) {
      Fluttertoast.showToast(msg: "Error registering user: $error");
      print("Error registering user: $error");
      _isRegistering = false;
      notifyListeners();
    } finally {
      _isRegistering = false;
      notifyListeners();
    }
  }
}



