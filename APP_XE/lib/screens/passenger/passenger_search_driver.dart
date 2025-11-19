import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_routes.dart';
import '../../providers/passenger_provider.dart';

class PassengerSearchDriver extends StatefulWidget {
  const PassengerSearchDriver({super.key});

  @override
  State<PassengerSearchDriver> createState() => _PassengerSearchDriverState();
}

class _PassengerSearchDriverState extends State<PassengerSearchDriver> {
  @override
  void initState() {
    super.initState();
    final provider = context.read<PassengerProvider>();
    provider.startDriverSearch(() {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.passengerDriverFound);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PassengerProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đang tìm tài xế'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.network(
              'https://assets2.lottiefiles.com/packages/lf20_GbabwrJMvY.json',
              width: 180,
              height: 180,
              repeat: true,
            ),
            const SizedBox(height: 24),
            Text(
              provider.isSearchingDriver ? 'Hệ thống đang tìm tài xế phù hợp...' : 'Đã tìm thấy tài xế!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              'Vui lòng giữ kết nối internet ổn định.',
              style: TextStyle(color: AppColors.textGray),
            ),
          ],
        ),
      ),
    );
  }
}

