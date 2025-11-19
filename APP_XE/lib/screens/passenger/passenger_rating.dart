import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_routes.dart';
import '../../providers/passenger_provider.dart';

class PassengerRating extends StatefulWidget {
  const PassengerRating({super.key});

  @override
  State<PassengerRating> createState() => _PassengerRatingState();
}

class _PassengerRatingState extends State<PassengerRating> {
  int currentRating = 5;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PassengerProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đánh giá chuyến đi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Bạn hài lòng như thế nào?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                final isActive = starIndex <= currentRating;
                return IconButton(
                  iconSize: 40,
                  onPressed: () => setState(() => currentRating = starIndex),
                  icon: Icon(
                    Icons.star,
                    color: isActive ? AppColors.primary : AppColors.lightGray,
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Chia sẻ cảm nhận của bạn...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: () {
                provider.resetTrip();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.passengerHome,
                  (route) => false,
                );
              },
              child: const Text('Gửi đánh giá & quay lại'),
            ),
          ],
        ),
      ),
    );
  }
}

