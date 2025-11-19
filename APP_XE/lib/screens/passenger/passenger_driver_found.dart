import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_routes.dart';
import '../../providers/passenger_provider.dart';

class PassengerDriverFound extends StatefulWidget {
  const PassengerDriverFound({super.key});

  @override
  State<PassengerDriverFound> createState() => _PassengerDriverFoundState();
}

class _PassengerDriverFoundState extends State<PassengerDriverFound> {
  final Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PassengerProvider>().startCarAnimation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PassengerProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đã tìm thấy tài xế'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 320,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: provider.currentCarPosition,
                zoom: 15,
              ),
              polylines: {
                if (provider.routePoints.isNotEmpty)
                  Polyline(
                    polylineId: const PolylineId('route'),
                    color: AppColors.primary,
                    width: 6,
                    points: provider.routePoints,
                  ),
              },
              markers: {
                Marker(
                  markerId: const MarkerId('driver'),
                  position: provider.currentCarPosition,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueAzure,
                  ),
                  infoWindow: const InfoWindow(title: 'Xe SwiftGo'),
                ),
              },
              onMapCreated: (controller) => _controller.complete(controller),
              myLocationButtonEnabled: false,
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(.2),
                        child: const Icon(Icons.person, color: AppColors.primary),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Nguyễn Quốc Anh',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          SizedBox(height: 4),
                          Text('Toyota Vios - 30G-88999'),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('⭐ 4.9'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Tài xế còn 3 phút sẽ tới điểm đón của bạn.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                    ),
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.passengerChat),
                    icon: const Icon(Icons.chat),
                    label: const Text('Trò chuyện với tài xế'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.passengerTripStatus),
                    child: const Text('Theo dõi hành trình'),
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

