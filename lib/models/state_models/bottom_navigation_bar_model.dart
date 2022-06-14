import 'package:flutter/material.dart';

class BottomNavigationBarModel with ChangeNotifier {
  int indexPage = 0;

  void goToPage(int index) {
    indexPage = index;
    notifyListeners();
  }
}
