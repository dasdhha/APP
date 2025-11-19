import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_routes.dart';
import '../../providers/passenger_provider.dart';

class PassengerTripStatus extends StatelessWidget {
  const PassengerTripStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PassengerProvider>();
    final isCompleted = provider.currentTripStep == provider.tripStatuses.length - 1;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trạng thái chuyến đi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Theo dõi lộ trình',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: provider.tripStatuses.length,
                itemBuilder: (context, index) {
                  final isActive = index <= provider.currentTripStep;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isActive ? AppColors.primary : AppColors.lightGray,
                      child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(provider.tripStatuses[index]),
                    subtitle: isActive ? const Text('Đã cập nhật') : null,
                  );
                },
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: isCompleted
                  ? () {
                      Navigator.pushReplacementNamed(context, AppRoutes.passengerRating);
                    }
                  : provider.advanceTripStep,
              child: Text(isCompleted ? 'Đánh giá chuyến đi' : 'Cập nhật trạng thái'),
            ),
          ],
        ),
      ),
    );
  }
}

