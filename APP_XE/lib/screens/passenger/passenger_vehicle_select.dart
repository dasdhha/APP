import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../providers/passenger_provider.dart';
import '../../widgets/vehicle_card.dart';

class PassengerVehicleSelect extends StatelessWidget {
  const PassengerVehicleSelect({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PassengerProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn phương tiện'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Các tuỳ chọn SwiftGo',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: provider.vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = provider.vehicles[index];
                  return VehicleCard(
                    vehicle: vehicle,
                    isSelected: provider.selectedVehicleIndex == index,
                    onTap: () => provider.selectVehicle(index),
                  );
                },
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Xác nhận lựa chọn'),
            ),
          ],
        ),
      ),
    );
  }
}

