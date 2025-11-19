import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../providers/passenger_provider.dart';

class VehicleCard extends StatelessWidget {
  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.isSelected,
    required this.onTap,
    this.width,
    this.margin,
  });

  final VehicleOption vehicle;
  final bool isSelected;
  final VoidCallback onTap;
  final double? width;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        width: width ?? double.infinity,
        margin: margin ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightGray,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              vehicle.icon,
              size: 36,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              vehicle.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              vehicle.description,
              style: const TextStyle(color: AppColors.textGray, fontSize: 12),
            ),
            const Spacer(),
            Text(
              vehicle.priceLabel,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

