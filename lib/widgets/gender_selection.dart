import 'package:flutter/material.dart';
import 'package:medallyproapp/constants/mycolors.dart';

enum Gender { male, female }

class GenderSelection extends StatefulWidget {
  GenderSelection({Key? key, required this.selectedGender, required this.onGenderChanged})
      : super(key: key);

  Gender selectedGender;
  final ValueChanged<String> onGenderChanged;

  @override
  _GenderSelectionState createState() => _GenderSelectionState();
}

class _GenderSelectionState extends State<GenderSelection> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 30.0),
        _buildGenderRadio(Gender.male, 'assets/images/male.png', 'Male', primaryColor),
        const SizedBox(width: 25.0),
        _buildGenderRadio(Gender.female, 'assets/images/female.png', 'Female', primaryColor),
      ],
    );
  }

  Widget _buildGenderRadio(Gender gender, String imageAsset, String labelText, Color radioColor) {
    bool isSelected = widget.selectedGender == gender;
    return Container(
      width: 120.0,
      height: 130.0, // Adjust the height as needed
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: isSelected ? primaryColor : textBlackColor.withOpacity(0.1),
          width: 2.0,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Radio<Gender>(
              value: gender,
              groupValue: widget.selectedGender,
              onChanged: (Gender? value) {
                // Update the parent widget's state using the callback
                widget.onGenderChanged(value == Gender.male ? 'male' : 'female');
              },
              activeColor: radioColor,
            ),
          ),
          Image.asset(
            imageAsset,
            width: 40,
            height: 40,
          ),
          const SizedBox(height: 5.0), // Adjust the spacing between image and text
          Text(
            labelText,
            style: TextStyle(
              fontSize: 16.0,
              color: textBlackColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 5.0), // Adjust the spacing between text and the bottom of the container
        ],
      ),
    );
  }
}






class SimpleGenderSelection extends StatefulWidget {
  String selectedGender;
  final ValueChanged<String> onGenderChanged;

   SimpleGenderSelection({
    Key? key,
    required this.selectedGender,
    required this.onGenderChanged,
  }) : super(key: key);

  @override
  _SimpleGenderSelectionState createState() => _SimpleGenderSelectionState();
}

class _SimpleGenderSelectionState extends State<SimpleGenderSelection> {
  // String selectedGender = 'male';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Radio(
              value: 'male',
              groupValue: widget.selectedGender,
              onChanged: (value) {
                setState(() {
                  widget.selectedGender = value!;
                });
              },
              activeColor: primaryColor,
            ),
            const Text('Male'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Radio(
              value: 'female',
              groupValue: widget.selectedGender,
              onChanged: (value) {
                setState(() {
                  widget.selectedGender = value!;
                });
              },
              activeColor: primaryColor,
            ),
            const Text('Female'),
          ],
        ),
      ],
    );
  }
}
