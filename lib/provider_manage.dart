import 'package:flutter/material.dart';

class ProviderManage with ChangeNotifier {
  String _deviceName = "HC-06";

  String get deviceName => _deviceName;

  void setDeviceName(String newName) {
    if (_deviceName != newName) {
      _deviceName = newName;
      notifyListeners();
    }
  }

  // Méthode pour réinitialiser le nom de l'appareil
  void resetDeviceName() {
    _deviceName = "BT";
    notifyListeners();
  }
}
