import 'package:flutter/material.dart';

class DexProvider with ChangeNotifier {
  bool normalMode = true;

  toggleMode() {
    normalMode = normalMode ? false : true;
    notifyListeners();
  }

  void func() {}
}
