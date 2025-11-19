import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

class DriverNewTripPopup extends StatelessWidget {
  const DriverNewTripPopup({
    super.key,
    required this.onAccept,
    required this.onReject,
  });

  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.electric_moped, size: 48, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              'Có chuyến mới',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hành khách: Trần Mai Chi\nĐiểm đón: Vincom Phạm Ngọc Thạch\nGiá cước: 78.000đ',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: onAccept,
              child: const Text('Nhận chuyến'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onReject,
              child: const Text('Từ chối'),
            ),
          ],
        ),
      ),
    );
  }
}

