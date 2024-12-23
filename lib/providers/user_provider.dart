import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? userId;
  String? username;

  void setUser(String id, String name) {
    userId = id;
    username = name;
    notifyListeners();
  }

  void clearUser() {
    userId = null;
    username = null;
    notifyListeners();
  }
}
