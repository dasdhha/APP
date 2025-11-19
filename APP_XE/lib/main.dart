import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_colors.dart';
import 'core/app_routes.dart';
import 'providers/driver_provider.dart';
import 'providers/passenger_provider.dart';
import 'providers/role_provider.dart';
import 'screens/driver/driver_home.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/passenger/passenger_chat_screen.dart';
import 'screens/passenger/passenger_driver_found.dart';
import 'screens/passenger/passenger_home.dart';
import 'screens/passenger/passenger_rating.dart';
import 'screens/passenger/passenger_search_driver.dart';
import 'screens/passenger/passenger_trip_status.dart';
import 'screens/passenger/passenger_vehicle_select.dart';
import 'screens/role_select_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SwiftGoApp());
}

class SwiftGoApp extends StatelessWidget {
  const SwiftGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RoleProvider()),
        ChangeNotifierProvider(create: (_) => PassengerProvider()),
        ChangeNotifierProvider(create: (_) => DriverProvider()),
      ],
      child: MaterialApp(
        title: 'SwiftGo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.onboarding: (_) => const OnboardingScreen(),
          AppRoutes.roleSelect: (_) => const RoleSelectScreen(),
          AppRoutes.passengerHome: (_) => const PassengerHome(),
          AppRoutes.passengerVehicleSelect: (_) => const PassengerVehicleSelect(),
          AppRoutes.passengerSearchDriver: (_) => const PassengerSearchDriver(),
          AppRoutes.passengerDriverFound: (_) => const PassengerDriverFound(),
          AppRoutes.passengerChat: (_) => const PassengerChatScreen(),
          AppRoutes.passengerTripStatus: (_) => const PassengerTripStatus(),
          AppRoutes.passengerRating: (_) => const PassengerRating(),
          AppRoutes.driverHome: (_) => const DriverHome(),
        },
      ),
    );
  }
}

