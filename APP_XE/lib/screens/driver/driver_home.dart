import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../providers/driver_provider.dart';
import 'driver_new_trip_popup.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  final Completer<GoogleMapController> _mapController = Completer();
  bool _dialogVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverProvider>().startListeningForTrips();
    });
  }

  void _showPopup(BuildContext context) {
    if (_dialogVisible) return;
    _dialogVisible = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => DriverNewTripPopup(
        onAccept: () {
          context.read<DriverProvider>().dismissPopup();
          Navigator.pop(context);
          _dialogVisible = false;
        },
        onReject: () {
          context.read<DriverProvider>().dismissPopup();
          Navigator.pop(context);
          _dialogVisible = false;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DriverProvider>();
    if (provider.showNewTripPopup) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showPopup(context));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('SwiftGo - Tài xế'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 280,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(21.028511, 105.804817),
                  zoom: 14.5,
                ),
                myLocationEnabled: true,
                zoomControlsEnabled: false,
                onMapCreated: (controller) => _mapController.complete(controller),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      _DriverStat(
                        title: 'Chuyến hoàn thành',
                        value: provider.completedTrips.toString(),
                      ),
                      const SizedBox(width: 16),
                      _DriverStat(
                        title: 'Đánh giá',
                        value: '${provider.rating}.0',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.shield, color: AppColors.primary),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Đừng quên bật chế độ sẵn sàng để nhận chuyến mới.',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                    ),
                    onPressed: () {},
                    child: const Text('Bật chế độ sẵn sàng'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverStat extends StatelessWidget {
  const _DriverStat({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.lightGray),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: AppColors.textGray),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

