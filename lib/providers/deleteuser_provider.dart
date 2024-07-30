import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:medallyproapp/constants/mycolors.dart';
import '../screens/prescription_list.dart';

class DeleteUserProvider extends ChangeNotifier {


  deleteUserInFirebase(BuildContext context, String userID) async {

    print("SecondUserID $userID");

    try {
      // Show CircularProgressIndicator
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Center(
            child: SpinKitCircle(
              color: primaryColor,
            )
          );
        },
      );

      // Delete data in Firestore
      await FirebaseFirestore.instance
          .collection('medicineDetail')
          .doc(userID)
          .delete();

      // Close the CircularProgressIndicator Dialog
      Navigator.pop(context);

      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Success"),
            content: const Text("Successfully deleted!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to PrescriptionListScreen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const PrescriptionListScreen()),
                  );
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    } catch (error) {
      // Close the CircularProgressIndicator Dialog on error
      Navigator.pop(context);

      print("Error deleting document: $error");

      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text("Failed to delete data. Error: $error"), // Print the exact error message
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }
}


