import 'package:flutter/material.dart';

class CameraVisibilityProvider with ChangeNotifier {
  bool _isCameraVisible = false;

  bool get isCameraVisible => _isCameraVisible;

  void toggleCameraVisibility() {
    _isCameraVisible = !_isCameraVisible;
    notifyListeners();
  }
}
