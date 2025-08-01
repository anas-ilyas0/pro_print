import 'package:flutter/material.dart';

class DashboardProvider with ChangeNotifier {
  int _selctedIndex = 0;
  int get selectedIndex => _selctedIndex;
  void setSelectedIndex(int index) {
    _selctedIndex = index;
    notifyListeners();
  }
}
