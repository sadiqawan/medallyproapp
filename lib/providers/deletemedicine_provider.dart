import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:medallyproapp/constants/mycolors.dart';
import '../screens/prescription_list.dart';

class DeleteMedicineProvider extends ChangeNotifier {
  User? user = FirebaseAuth.instance.currentUser;

  Future<void> deleteDataInFirebase(BuildContext context, String documentId) async {
    print("DocumentID $documentId");

    try {
      // Check if the document exists
      bool doesDocumentExist = await FirebaseFirestore.instance
          .collection('medicineDetail')
          .doc(user!.uid)
          .collection('medicines')
          .doc(documentId)
          .get()
          .then((doc) => doc.exists);

      if (!doesDocumentExist) {
        print("Document does not exist with ID: $documentId");
        // Handle accordingly, e.g., show an error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: const Text("Document not found"),
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
        return;
      }

      // Show CircularProgressIndicator
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(color: primaryColor),
          );
        },
      );

      // Delete data in Firestore
      await FirebaseFirestore.instance
          .collection('medicineDetail')
          .doc(user!.uid)
          .collection('medicines')
          .doc(documentId)
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

      // Show error dialog with the exact error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text("Failed to delete data. Error: $error"),
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

