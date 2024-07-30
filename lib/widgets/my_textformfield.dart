import 'package:flutter/material.dart';
import 'package:medallyproapp/constants/mycolors.dart';

class MyTextFormField extends StatelessWidget {
  MyTextFormField({
    Key? key,
    required this.hintText,
    required this.labelText,
    required this.controller,
    required this.enabledBorderColor,
    required this.focusedBorderColor,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onTap,
    required this.readOnly,
  }) : super(key: key);

  bool readOnly;
  String hintText;
  String labelText;
  TextEditingController controller;
  Widget? suffixIcon;
  Color enabledBorderColor;
  Color focusedBorderColor;
  TextInputType? keyboardType;
  String? Function(String?)? validator;
  String? Function(String)? onChanged;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.0,
      child: TextFormField(
        readOnly: readOnly!,
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          suffixIcon: suffixIcon,
          hintStyle: TextStyle(color: textBlackColor.withOpacity(0.5), fontSize: 14.0),
          labelStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7.0),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7.0),
            borderSide: BorderSide(color: enabledBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7.0),
            borderSide: BorderSide(color: focusedBorderColor),
          ),
        ),
      ),
    );
  }
}

