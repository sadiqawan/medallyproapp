import 'package:flutter/material.dart';
import 'package:medallyproapp/constants/mycolors.dart';

class CustomToast {
  static void showToast(BuildContext context, String message) {
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 350.0,
        width: MediaQuery.of(context).size.width,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            decoration: BoxDecoration(
              color: primaryColor, // Customize background color
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              message,
              style: const TextStyle(fontSize: 16.0, color: textColor),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    // You can adjust the duration based on your needs
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}