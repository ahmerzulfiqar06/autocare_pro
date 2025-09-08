import 'package:flutter/material.dart';
import 'package:autocare_pro/presentation/screens/dashboard_screen.dart';
import 'package:autocare_pro/presentation/screens/vehicle_list_screen.dart';
import 'package:autocare_pro/presentation/screens/add_vehicle_screen.dart';

class Routes {
  static const String dashboard = '/';
  static const String vehicleList = '/vehicles';
  static const String vehicleDetails = '/vehicle-details';
  static const String addVehicle = '/add-vehicle';
  static const String addService = '/add-service';
  static const String serviceList = '/service-list';
  static const String serviceDetails = '/service-details';
  static const String analytics = '/analytics';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      dashboard: (context) => const DashboardScreen(),
      vehicleList: (context) => const VehicleListScreen(),
      vehicleDetails: (context) => const _PlaceholderScreen('Vehicle Details'),
      addVehicle: (context) => const AddVehicleScreen(),
      addService: (context) => const _PlaceholderScreen('Add Service'),
      serviceList: (context) => const _PlaceholderScreen('Service List'),
      serviceDetails: (context) => const _PlaceholderScreen('Service Details'),
      analytics: (context) => const _PlaceholderScreen('Analytics'),
      settings: (context) => const _PlaceholderScreen('Settings'),
    };
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title Screen\n\n🚗 AutoCare Pro is Running! ✨',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
