import 'package:flutter/material.dart';

class TimeProvider extends ChangeNotifier {
  List<String> selectedTimes = [];

  void addTime(String time) {
    selectedTimes.add(time);
    notifyListeners();
  }

  void editTime(int index, String newTime) {
    if (index >= 0 && index < selectedTimes.length) {
      selectedTimes[index] = newTime;
      notifyListeners();
    }
  }

  void clearSelectedTimes() {
    selectedTimes.clear();
    notifyListeners();
  }
}
