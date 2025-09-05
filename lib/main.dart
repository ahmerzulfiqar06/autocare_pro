import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:autocare_pro/config/routes.dart';
import 'package:autocare_pro/core/theme/app_theme.dart';
import 'package:autocare_pro/data/repositories/vehicle_repository.dart';
import 'package:autocare_pro/data/repositories/service_repository.dart';
import 'package:autocare_pro/data/services/database_service.dart';
import 'package:autocare_pro/presentation/providers/app_provider.dart';
import 'package:autocare_pro/presentation/providers/vehicle_provider.dart';
import 'package:autocare_pro/presentation/providers/service_provider.dart';

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
