import 'dart:async';

import 'package:flutter/material.dart';

class DriverProvider extends ChangeNotifier {
  Timer? _tripTimer;
  bool showNewTripPopup = false;
  int completedTrips = 128;
  int rating = 5;

  void startListeningForTrips() {
    _tripTimer?.cancel();
    _tripTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      showNewTripPopup = true;
      notifyListeners();
    });
  }

  void dismissPopup() {
    showNewTripPopup = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _tripTimer?.cancel();
    super.dispose();
  }
}

