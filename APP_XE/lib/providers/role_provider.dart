import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleProvider extends ChangeNotifier {
  static const _roleKey = 'swiftgo_role';

  String? _currentRole;
  bool _isLoaded = false;

  String? get currentRole => _currentRole;
  bool get isLoaded => _isLoaded;

  Future<void> loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    _currentRole = prefs.getString(_roleKey);
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setRole(String role) async {
    _currentRole = role;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
    notifyListeners();
  }

  bool get isPassenger => _currentRole == 'passenger';
  bool get isDriver => _currentRole == 'driver';
}

