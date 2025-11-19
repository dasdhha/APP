import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_routes.dart';
import '../../providers/passenger_provider.dart';
import '../../widgets/vehicle_card.dart';

class PassengerHome extends StatefulWidget {
  const PassengerHome({super.key});

  @override
  State<PassengerHome> createState() => _PassengerHomeState();
}

class _PassengerHomeState extends State<PassengerHome> {
  final Completer<GoogleMapController> _mapController = Completer();

  Set<Marker> _buildMarkers(PassengerProvider provider) {
    return {
      Marker(
        markerId: const MarkerId('pickup'),
        position: provider.hanoiCenter,
        infoWindow: const InfoWindow(title: 'Điểm đón'),
      ),
      const Marker(
        markerId: MarkerId('dropoff'),
        position: LatLng(21.035, 105.814),
        infoWindow: InfoWindow(title: 'Điểm đến'),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PassengerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SwiftGo - Hành khách'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.passengerVehicleSelect);
            },
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 300,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: provider.hanoiCenter,
                      zoom: 14.5,
                    ),
                    onMapCreated: (controller) => _mapController.complete(controller),
                    markers: _buildMarkers(provider),
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Chọn phương tiện',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 170,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = provider.vehicles[index];
                    return VehicleCard(
                      vehicle: vehicle,
                      isSelected: provider.selectedVehicleIndex == index,
                      onTap: () => provider.selectVehicle(index),
                      width: 180,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.lightGray),
                ),
                child: Column(
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.location_on, color: AppColors.primary),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Điểm đón: 54 Liễu Giai, Hà Nội',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: const [
                        Icon(Icons.flag, color: AppColors.primary),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Điểm đến: Hồ Gươm, Hoàn Kiếm',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.passengerSearchDriver);
                },
                child: const Text('Tìm tài xế ngay'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

