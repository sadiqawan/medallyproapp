import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';


class HandlePermissionDenied extends StatelessWidget {
  const HandlePermissionDenied({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Permission Required"),
      content: const Text("You have permanently denied camera permission. "
          "Please go to app settings and enable the permission."),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            openAppSettings();
          },
          child: const Text("Open Settings"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
