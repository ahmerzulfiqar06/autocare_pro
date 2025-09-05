class AppConstants {
  // App information
  static const String appName = 'AutoCare Pro';
  static const String appVersion = '1.0.0';

  // Database
  static const String databaseName = 'autocare_pro.db';
  static const int databaseVersion = 1;

  // Table names
  static const String vehiclesTable = 'vehicles';
  static const String servicesTable = 'services';
  static const String serviceSchedulesTable = 'service_schedules';

  // Default service intervals (in miles and months)
  static const Map<String, Map<String, int>> defaultServiceIntervals = {
    'Oil Change': {'miles': 5000, 'months': 6},
    'Tire Rotation': {'miles': 8000, 'months': 6},
    'Brake Service': {'miles': 50000, 'months': 24},
    'Transmission Service': {'miles': 30000, 'months': 24},
    'Engine Tune-up': {'miles': 30000, 'months': 24},
    'Air Filter Replacement': {'miles': 15000, 'months': 12},
    'Battery Replacement': {'miles': 50000, 'months': 48},
    'Coolant Flush': {'miles': 30000, 'months': 24},
    'Inspection': {'miles': 10000, 'months': 12},
  };

  // Date formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'MMM dd, yyyy HH:mm';

  // Currency
  static const String currencySymbol = '\$';
  static const String currencyFormat = '\$#,##0.00';

  // Mileage
  static const String mileageUnit = 'miles';
  static const String mileageFormat = '#,##0';

  // File paths
  static const String vehiclesPhotosPath = 'vehicles';
  static const String receiptsPath = 'receipts';

  // Shared preferences keys
  static const String themeModeKey = 'theme_mode';
  static const String notificationsEnabledKey = 'notifications_enabled';
  static const String lastBackupKey = 'last_backup';

  // Notification settings
  static const int defaultReminderDays = 7;
  static const int defaultReminderMiles = 500;

  // UI constants
  static const double borderRadius = 8.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double cardElevation = 2.0;

  // Animation durations
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationLong = Duration(milliseconds: 500);

  // Error messages
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'Network error. Please check your connection.';
  static const String validationErrorMessage = 'Please check your input and try again.';

  // Success messages
  static const String saveSuccessMessage = 'Saved successfully';
  static const String deleteSuccessMessage = 'Deleted successfully';
  static const String updateSuccessMessage = 'Updated successfully';

  // Loading messages
  static const String loadingMessage = 'Loading...';
  static const String savingMessage = 'Saving...';
  static const String deletingMessage = 'Deleting...';

  // Empty state messages
  static const String noVehiclesMessage = 'No vehicles added yet';
  static const String noServicesMessage = 'No services recorded yet';
  static const String noSchedulesMessage = 'No maintenance schedules set up yet';

  // Permissions
  static const String cameraPermissionMessage = 'Camera permission is required to take photos';
  static const String storagePermissionMessage = 'Storage permission is required to save files';

  // Limits
  static const int maxPhotoSize = 5 * 1024 * 1024; // 5MB
  static const int maxVehicles = 50;
  static const int maxServicesPerVehicle = 1000;

  // Colors (Material Design 3)
  static const int primaryColorValue = 0xFF1565C0;
  static const int secondaryColorValue = 0xFF42A5F5;
  static const int errorColorValue = 0xFFD32F2F;
  static const int successColorValue = 0xFF388E3C;
  static const int warningColorValue = 0xFFF57C00;
}
