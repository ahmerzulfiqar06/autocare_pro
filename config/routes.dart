import 'package:flutter/material.dart';
import 'package:autocare_pro/presentation/screens/dashboard_screen.dart';
import 'package:autocare_pro/presentation/screens/vehicle_list_screen.dart';
import 'package:autocare_pro/presentation/screens/add_vehicle_screen.dart';
import 'package:autocare_pro/presentation/screens/vehicle_details_screen.dart';

class Routes {
  // Route names
  static const String dashboard = '/';
  static const String vehicleList = '/vehicles';
  static const String vehicleDetails = '/vehicle-details';
  static const String addVehicle = '/add-vehicle';
  static const String addService = '/add-service';
  static const String serviceHistory = '/service-history';
  static const String analytics = '/analytics';
  static const String settings = '/settings';

  // Get all routes
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      dashboard: (context) => const DashboardScreen(),
      vehicleList: (context) => const VehicleListScreen(),
      vehicleDetails: (context) => VehicleDetailsScreen(
        vehicleId: ModalRoute.of(context)!.settings.arguments as String,
      ),
      addVehicle: (context) => const AddVehicleScreen(),
      addService: (context) => const _PlaceholderScreen('Add Service'),
      serviceHistory: (context) => const _PlaceholderScreen('Service History'),
      analytics: (context) => const _PlaceholderScreen('Analytics'),
      settings: (context) => const _PlaceholderScreen('Settings'),
    };
  }

  // Navigate to route
  static Future<T?> navigateTo<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  // Replace current route
  static Future<T?> replaceWith<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushReplacementNamed<T, dynamic>(context, routeName, arguments: arguments);
  }

  // Go back
  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  // Go back with result
  static void goBackWithResult<T>(BuildContext context, T result) {
    Navigator.pop(context, result);
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
