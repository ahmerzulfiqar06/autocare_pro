import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:autocare_pro/config/routes.dart';
import 'package:autocare_pro/core/theme/app_theme.dart';
import 'package:autocare_pro/data/repositories/vehicle_repository.dart';
import 'package:autocare_pro/data/repositories/service_repository.dart';
import 'package:autocare_pro/data/services/database_service.dart';
import 'package:autocare_pro/presentation/providers/app_provider.dart';
import 'package:autocare_pro/presentation/providers/vehicle_provider.dart';
import 'package:autocare_pro/presentation/providers/service_provider.dart';

// Temporary Routes class
class Routes {
  static const String dashboard = '/';
  static const String vehicleList = '/vehicles';
  static const String vehicleDetails = '/vehicle-details';
  static const String addVehicle = '/add-vehicle';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      dashboard: (context) => const _PlaceholderScreen('Dashboard'),
      vehicleList: (context) => const _PlaceholderScreen('Vehicle List'),
      vehicleDetails: (context) => const _PlaceholderScreen('Vehicle Details'),
      addVehicle: (context) => const _PlaceholderScreen('Add Vehicle'),
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database and repositories
  final databaseService = DatabaseService();
  final vehicleRepository = VehicleRepository(databaseService);
  final serviceRepository = ServiceRepository(databaseService);

  // Initialize app provider
  final appProvider = AppProvider();
  await appProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appProvider),
        Provider.value(value: databaseService),
        Provider.value(value: vehicleRepository),
        Provider.value(value: serviceRepository),
        ChangeNotifierProvider(
          create: (context) => VehicleProvider(vehicleRepository),
        ),
        ChangeNotifierProvider(
          create: (context) => ServiceProvider(serviceRepository),
        ),
      ],
      child: const AutoCareProApp(),
    ),
  );
}

class AutoCareProApp extends StatelessWidget {
  const AutoCareProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return MaterialApp(
          title: 'AutoCare Pro',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: appProvider.themeMode,
          initialRoute: Routes.dashboard,
          routes: Routes.getRoutes(),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: 1.0, // Prevent system font scaling
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}
