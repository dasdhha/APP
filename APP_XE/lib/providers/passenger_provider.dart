import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class VehicleOption {
  VehicleOption({
    required this.name,
    required this.priceLabel,
    required this.icon,
    required this.description,
  });

  final String name;
  final String priceLabel;
  final IconData icon;
  final String description;
}

class PassengerProvider extends ChangeNotifier {
  final List<VehicleOption> vehicles = [
    VehicleOption(
      name: 'Xe máy',
      priceLabel: '65k',
      icon: Icons.pedal_bike,
      description: 'Nhanh gọn cho quãng ngắn',
    ),
    VehicleOption(
      name: 'Ô tô 4 chỗ',
      priceLabel: '128k',
      icon: Icons.directions_car_filled,
      description: 'Thoải mái cho 1-3 người',
    ),
    VehicleOption(
      name: 'Ô tô 7 chỗ',
      priceLabel: '178k',
      icon: Icons.airport_shuttle,
      description: 'Rộng rãi cho gia đình',
    ),
  ];

  int selectedVehicleIndex = 0;
  bool isSearchingDriver = false;
  bool driverFound = false;

  final LatLng hanoiCenter = const LatLng(21.028511, 105.804817);
  final String _encodedRoute = 'ecj_Cc_xdSiH{RsNsNsN{T';

  List<LatLng> routePoints = [];
  int carMarkerIndex = 0;

  final List<String> tripStatuses = [
    'Tài xế đang đến',
    'Đã đến điểm đón',
    'Đang di chuyển',
    'Đã hoàn thành chuyến'
  ];
  int currentTripStep = 0;

  Timer? _searchTimer;
  Timer? _carTimer;

  List<Map<String, String>> chatMessages = [
    {'sender': 'Bạn', 'message': 'Chào anh/chị tài xế ạ!'},
    {'sender': 'Tài xế', 'message': 'Xin chào, tôi đang đến trong 3 phút.'},
    {'sender': 'Bạn', 'message': 'Em đang đứng trước cổng nhé.'},
  ];

  PassengerProvider() {
    _decodeRoute();
  }

  void _decodeRoute() {
    final result = PolylinePoints().decodePolyline(_encodedRoute);
    if (result.isNotEmpty) {
      routePoints = result
          .map(
            (point) => LatLng(point.latitude, point.longitude),
          )
          .toList();
    } else {
      routePoints = [
        hanoiCenter,
        const LatLng(21.0300, 105.8080),
        const LatLng(21.0325, 105.8105),
        const LatLng(21.0350, 105.8140),
      ];
    }
  }

  void selectVehicle(int index) {
    selectedVehicleIndex = index;
    notifyListeners();
  }

  void startDriverSearch(VoidCallback onDriverFound) {
    if (isSearchingDriver) return;
    isSearchingDriver = true;
    driverFound = false;
    notifyListeners();

    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(seconds: 3), () {
      driverFound = true;
      isSearchingDriver = false;
      notifyListeners();
      onDriverFound();
    });
  }

  void startCarAnimation() {
    if (routePoints.isEmpty) return;
    carMarkerIndex = 0;
    _carTimer?.cancel();
    _carTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (carMarkerIndex < routePoints.length - 1) {
        carMarkerIndex++;
        notifyListeners();
      } else {
        _carTimer?.cancel();
      }
    });
  }

  LatLng get currentCarPosition {
    if (routePoints.isEmpty) {
      return hanoiCenter;
    }
    return routePoints[carMarkerIndex];
  }

  void advanceTripStep() {
    if (currentTripStep < tripStatuses.length - 1) {
      currentTripStep++;
      notifyListeners();
    }
  }

  void resetTrip() {
    carMarkerIndex = 0;
    currentTripStep = 0;
    driverFound = false;
    isSearchingDriver = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _carTimer?.cancel();
    super.dispose();
  }
}

