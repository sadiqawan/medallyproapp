import 'package:flutter/material.dart';

class TimeProvider extends ChangeNotifier {
  List<String> selectedTimes = [];

  void addTime(String time) {
    selectedTimes.add(time);
    notifyListeners();
  }

  void clearSelectedTimes() {
    selectedTimes.clear();
    notifyListeners();
  }
}
