import 'package:flutter/material.dart';
import '../constants/mycolors.dart';

class CustomButton extends StatelessWidget {
  CustomButton({super.key, required this.text});

  String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 30.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: primaryColor,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18.0,
          color: textColor,
          fontFamily: 'GT Walsheim Trial',
        ),
      ),
    );
  }
}
