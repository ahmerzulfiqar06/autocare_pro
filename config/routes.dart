import 'package:flutter/material.dart';

class Routes {
  // Route names
  static const String dashboard = '/';
  static const String vehicleList = '/vehicles';
  static const String vehicleDetails = '/vehicle-details';
  static const String addVehicle = '/add-vehicle';

  // Get all routes
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      dashboard: (context) => const _PlaceholderScreen('Dashboard'),
      vehicleList: (context) => const _PlaceholderScreen('Vehicle List'),
      vehicleDetails: (context) => const _PlaceholderScreen('Vehicle Details'),
      addVehicle: (context) => const _PlaceholderScreen('Add Vehicle'),
    };
  }
}

// Temporary placeholder screen for development
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          '$title Screen\n\nComing Soon!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
