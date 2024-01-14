import 'package:flutter/material.dart';
import '../constants/mycolors.dart';

class FloatingButton extends StatelessWidget {
  const FloatingButton({super.key, required this.function});
  final VoidCallback function;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      backgroundColor: primaryColor,
      hoverColor: primaryColor.withOpacity(0.2),
      onPressed: function,
      child: const Icon(
        Icons.add,
        color: textColor,
      ),
    );
  }
}
