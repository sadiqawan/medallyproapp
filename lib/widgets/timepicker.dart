import 'package:flutter/material.dart';
import 'package:medallyproapp/constants/mycolors.dart';
import 'package:provider/provider.dart';
import '../providers/time_provider.dart';

class TimePickerRow extends StatefulWidget {
  const TimePickerRow({super.key});

  @override
  _TimePickerRowState createState() => _TimePickerRowState();
}

class _TimePickerRowState extends State<TimePickerRow> {
  TimeProvider? timeProvider;

  @override
  Widget build(BuildContext context) {
    timeProvider = Provider.of<TimeProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            for (var i = 0; i < timeProvider!.selectedTimes.length; i++)
              TimeContainer(
                time: timeProvider!.selectedTimes[i],
                onTap: () => _editTime(i),
              ),
            AddButton(
              onPressed: () => _showTimePicker(),
            ),
          ],
        ),
      ],
    );
  }

  void _showTimePicker() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      String formattedTime = _formatTime(pickedTime.hour, pickedTime.minute);
      setState(() {
        timeProvider!.addTime(formattedTime);
      });
    }
  }

  void _editTime(int index) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      String formattedTime = _formatTime(pickedTime.hour, pickedTime.minute);
      setState(() {
        timeProvider!.editTime(index, formattedTime);
      });
    }
  }

  String _formatTime(int hour, int minute) {
    String period = 'AM';

    if (hour >= 12) {
      period = 'PM';

      if (hour > 12) {
        hour -= 12;
      }
    }

    if (hour == 0) {
      hour = 12;
    }

    return '$hour:${minute.toString().padLeft(2, '0')} $period';
  }
}

class TimeContainer extends StatelessWidget {
  final String time;
  final VoidCallback onTap;

  const TimeContainer({
    Key? key,
    required this.time,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.0,
        width: 95.0,
        margin: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: primaryColor),
        ),
        child: Text(
          time,
          style: const TextStyle(
            fontSize: 14.0,
            color: textBlackColor,
            fontFamily: 'GT Walsheim Trial',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}


class AddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddButton({super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 40.0,
        width: 95.0,
        margin: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: primaryColor, // Replace with your primaryColor
        ),
        child: const Text(
          "Add Time",
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.white,
            fontFamily: 'GT Walsheim Trial',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}