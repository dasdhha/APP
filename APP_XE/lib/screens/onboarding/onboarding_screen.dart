import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/app_colors.dart';
import '../../core/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentIndex = 0;

  final List<_OnboardingData> _slides = [
    _OnboardingData(
      title: 'Đặt xe cực nhanh',
      description: 'Chọn điểm đón và hành trình trong vài giây.',
      imageUrl: 'https://i.imgur.com/8gD3Z8K.png',
    ),
    _OnboardingData(
      title: 'Tài xế thân thiện',
      description: 'Đội ngũ tài xế chuyên nghiệp, tận tâm.',
      imageUrl: 'https://i.imgur.com/5vZ8Y9L.png',
    ),
    _OnboardingData(
      title: 'Theo dõi theo thời gian thực',
      description: 'Giám sát hành trình và chia sẻ với người thân.',
      imageUrl: 'https://i.imgur.com/kP9mX2j.png',
    ),
  ];

  void _goNext() {
    if (_currentIndex == _slides.length - 1) {
      Navigator.pushReplacementNamed(context, AppRoutes.roleSelect);
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Image.network(slide.imageUrl),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textGray),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SmoothPageIndicator(
              controller: _controller,
              count: _slides.length,
              effect: ExpandingDotsEffect(
                expansionFactor: 3,
                spacing: 8,
                activeDotColor: AppColors.primary,
                dotColor: AppColors.lightGray,
                dotHeight: 10,
                dotWidth: 10,
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.roleSelect,
                    ),
                    child: const Text('Bỏ qua'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                    ),
                    onPressed: _goNext,
                    child: Text(
                      _currentIndex == _slides.length - 1 ? 'Bắt đầu' : 'Tiếp tục',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  final String title;
  final String description;
  final String imageUrl;
}

