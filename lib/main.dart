import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:autocare_pro/core/theme/app_theme.dart';
import 'package:autocare_pro/data/repositories/vehicle_repository.dart';
import 'package:autocare_pro/data/repositories/service_repository.dart';
import 'package:autocare_pro/data/services/database_service.dart';
import 'package:autocare_pro/data/services/camera_service.dart';
import 'package:autocare_pro/data/services/notification_service.dart';
import 'package:autocare_pro/data/services/notification_manager.dart';
import 'package:autocare_pro/data/services/connectivity_service.dart';
import 'package:autocare_pro/presentation/providers/app_provider.dart';
import 'package:autocare_pro/presentation/providers/vehicle_provider.dart';
import 'package:autocare_pro/presentation/providers/service_provider.dart';
import 'package:autocare_pro/presentation/screens/dashboard_screen.dart';
import 'package:autocare_pro/presentation/screens/vehicle_list_screen.dart';
import 'package:autocare_pro/presentation/screens/vehicle_details_screen.dart';
import 'package:autocare_pro/presentation/screens/add_vehicle_screen.dart';
import 'package:autocare_pro/presentation/screens/service_list_screen.dart';
import 'package:autocare_pro/presentation/screens/add_service_screen.dart';
import 'package:autocare_pro/presentation/screens/service_details_screen.dart';
import 'package:autocare_pro/presentation/screens/analytics_screen.dart';
import 'package:autocare_pro/presentation/screens/settings_screen.dart';
import 'package:autocare_pro/presentation/screens/splash_screen.dart';
import 'package:autocare_pro/presentation/screens/search_screen.dart';

// Route constants
class Routes {
  static const String splash = '/splash';
  static const String dashboard = '/';
  static const String vehicleList = '/vehicles';
  static const String vehicleDetails = '/vehicle-details';
  static const String addVehicle = '/add-vehicle';
  static const String addService = '/add-service';
  static const String serviceList = '/service-list';
  static const String serviceDetails = '/service-details';
  static const String analytics = '/analytics';
  static const String settings = '/settings';
  static const String search = '/search';
}

// Route definitions
Map<String, WidgetBuilder> _getRoutes() {
  return {
    Routes.splash: (context) => const SplashScreen(),
    Routes.dashboard: (context) => const DashboardScreen(),
    Routes.vehicleList: (context) => const VehicleListScreen(),
    Routes.vehicleDetails: (context) {
      final vehicleId = ModalRoute.of(context)?.settings.arguments as String?;
      if (vehicleId != null) {
        return VehicleDetailsScreen(vehicleId: vehicleId);
      }
      return const Scaffold(
        body: Center(child: Text('Vehicle ID not provided')),
      );
    },
    Routes.addVehicle: (context) => const AddVehicleScreen(),
    Routes.addService: (context) {
      final vehicleId = ModalRoute.of(context)?.settings.arguments as String?;
      return AddServiceScreen(vehicleId: vehicleId);
    },
    Routes.serviceList: (context) {
      final vehicleId = ModalRoute.of(context)?.settings.arguments as String?;
      if (vehicleId != null) {
        return ServiceListScreen(vehicleId: vehicleId);
      }
      return const Scaffold(
        body: Center(child: Text('Vehicle ID not provided')),
      );
    },
    Routes.serviceDetails: (context) {
      final serviceId = ModalRoute.of(context)?.settings.arguments as String?;
      if (serviceId != null) {
        return ServiceDetailsScreen(serviceId: serviceId);
      }
      return const Scaffold(
        body: Center(child: Text('Service ID not provided')),
      );
    },
    Routes.analytics: (context) => const AnalyticsScreen(),
    Routes.settings: (context) => const SettingsScreen(),
    Routes.search: (context) => const SearchScreen(),
  };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database and repositories
  final databaseService = DatabaseService();
  final vehicleRepository = VehicleRepository(databaseService);
  final serviceRepository = ServiceRepository(databaseService);
  final cameraService = CameraService();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Initialize notification manager
  final notificationManager = NotificationManager(
    notificationService: notificationService,
  );

  // Initialize connectivity service
  final connectivityService = ConnectivityService();
  await connectivityService.initialize();

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
        Provider.value(value: cameraService),
        Provider.value(value: notificationService),
        Provider.value(value: notificationManager),
        ChangeNotifierProvider.value(value: connectivityService),
        ChangeNotifierProvider(
          create: (context) => VehicleProvider(vehicleRepository),
        ),
        ChangeNotifierProvider(
          create: (context) => ServiceProvider(serviceRepository)..loadAllActiveSchedules(),
        ),
      ],
      child: FutureBuilder(
        future: _initializeNotifications(notificationManager),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }

          return const AutoCareProApp();
        },
      ),
    ),
  );
}

Future<void> _initializeNotifications(NotificationManager notificationManager) async {
  // Initialize smart notifications after app setup
  await notificationManager.initializeSmartNotifications();
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
          initialRoute: Routes.splash,
          routes: _getRoutes(),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: 1.0, // Prevent system font scaling
              ),
              child: Column(
                children: [
                  // Connection status indicator
                  const ConnectionStatusIndicator(),
                  // Main app content
                  Expanded(
                    child: child!,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}