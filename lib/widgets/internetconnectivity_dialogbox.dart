import 'package:flutter/material.dart';


class InternetConnectivityDialogBoxWidget extends StatelessWidget {
  const InternetConnectivityDialogBoxWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('No Internet Connection'),
      content: const Text(
          'Please check your internet connection and try again.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
