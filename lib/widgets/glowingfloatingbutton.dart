import 'package:flutter/material.dart';

import '../constants/mycolors.dart';

class GlowingFloatingActionButton extends StatelessWidget {
  const GlowingFloatingActionButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50.0,
      height: 50.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: containerBorderColor.withOpacity(0.8),
            spreadRadius: 2,
            blurRadius: 3,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: FloatingActionButton.small(
        onPressed: onPressed,
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}