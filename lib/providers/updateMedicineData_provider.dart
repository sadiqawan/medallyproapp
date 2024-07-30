import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../constants/mycolors.dart';
import '../screens/prescription_list.dart';

class MedicineProvider extends ChangeNotifier {

  User? user = FirebaseAuth.instance.currentUser;

  Future<void> updateDataInFirebase(
      BuildContext context,
      String nameOfMedicine,
      prescriptionNote,
      medicineType,
      durationOfMedicine,
      medicineIntake,
      List medicineTimes,
      String documentId,
      ) async {

    // Prepare the data to be updated
    Map<String, dynamic> updatedData = {
      'medicineName': nameOfMedicine,
      'note': prescriptionNote,
      'duration': durationOfMedicine,
      'intake': medicineIntake,
      'typeOfMedicine': medicineType,
      'time': medicineTimes,
    };

    try {
      // Check for internet connectivity
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        // Show CircularProgressIndicator
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Center(
              child: SpinKitCircle(
                color: primaryColor,
              )
            );
          },
        );

        // Update data in Firestore
        await FirebaseFirestore.instance
            .collection('medicineDetail')
            .doc(user!.uid)
            .collection('medicines')
            .doc(documentId)
            .update(updatedData);

        // Close the CircularProgressIndicator Dialog
        Navigator.pop(context);

        // Show Toast for successful update
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Successfully updated!"),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to PrescriptionListScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PrescriptionListScreen()),
        );
      } else {
        // Close the CircularProgressIndicator Dialog
        Navigator.pop(context);

        // Show error dialog for no internet connectivity
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: const Text("No internet connection"),
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
    } catch (error) {
      // Close the CircularProgressIndicator Dialog on error
      Navigator.pop(context);

      print("Error updating document: $error");

      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text("Failed to update data"),
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
