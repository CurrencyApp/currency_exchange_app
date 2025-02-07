import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _userId = '';

  String get userId => _userId;

  // Define the method to set the userId
  void setUserId(String id) {
    _userId = id;
    notifyListeners(); // Notify listeners to update the UI
  }
}
