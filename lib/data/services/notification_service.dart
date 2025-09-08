import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:autocare_pro/data/models/service.dart';
import 'package:autocare_pro/data/models/vehicle.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Initialize notification settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void _onNotificationTapped(NotificationResponse notificationResponse) {
    // Handle notification tap
    final payload = notificationResponse.payload;
    if (payload != null) {
      // Navigate to relevant screen based on payload
      // This would typically trigger navigation in the app
    }
  }

  // Schedule service reminders
  Future<void> scheduleServiceReminder({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'service_reminders',
        'Service Reminders',
        channelDescription: 'Reminders for vehicle maintenance services',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      );

      const DarwinNotificationDetails iosNotificationDetails =
          DarwinNotificationDetails();

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iosNotificationDetails,
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        int.parse(id),
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      throw Exception('Failed to schedule notification: $e');
    }
  }

  // Cancel specific notification
  Future<void> cancelNotification(String id) async {
    await _flutterLocalNotificationsPlugin.cancel(int.parse(id));
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Schedule upcoming service reminders
  Future<void> scheduleUpcomingServiceReminders(
    List<Service> services,
    List<Vehicle> vehicles,
  ) async {
    // Cancel existing notifications first
    await cancelAllNotifications();

    final now = DateTime.now();
    final vehicleMap = {for (final v in vehicles) v.id: v};

    for (final service in services) {
      final vehicle = vehicleMap[service.vehicleId];
      if (vehicle == null) continue;

      // Schedule reminders for different intervals
      final reminderIntervals = [
        const Duration(days: 30), // 1 month before
        const Duration(days: 14), // 2 weeks before
        const Duration(days: 7),  // 1 week before
        const Duration(days: 1),  // 1 day before
      ];

      for (final interval in reminderIntervals) {
        final reminderDate = service.serviceDate.subtract(interval);

        // Only schedule if reminder is in the future
        if (reminderDate.isAfter(now)) {
          final notificationId = '${service.id}_${interval.inDays}';

          await scheduleServiceReminder(
            id: notificationId.hashCode.toString(),
            title: 'Service Reminder: ${vehicle.make} ${vehicle.model}',
            body: '${service.serviceType.displayName} due in ${interval.inDays} day${interval.inDays != 1 ? 's' : ''}',
            scheduledDate: reminderDate,
            payload: 'service_${service.id}',
          );
        }
      }

      // Schedule post-service follow-up
      final followUpDate = service.serviceDate.add(const Duration(days: 1));
      if (followUpDate.isAfter(now)) {
        final notificationId = '${service.id}_followup';

        await scheduleServiceReminder(
          id: notificationId.hashCode.toString(),
          title: 'Service Completed',
          body: '${service.serviceType.displayName} completed for ${vehicle.make} ${vehicle.model}',
          scheduledDate: followUpDate,
          payload: 'service_completed_${service.id}',
        );
      }
    }
  }

  // Schedule regular maintenance reminders
  Future<void> scheduleRegularMaintenanceReminders(List<Vehicle> vehicles) async {
    final now = DateTime.now();

    for (final vehicle in vehicles) {
      // Oil change reminder (every 3 months or 3000 miles)
      final lastOilChange = _getLastServiceDate(vehicles, vehicle.id, ServiceType.oilChange);
      if (lastOilChange != null) {
        final nextOilChange = lastOilChange.add(const Duration(days: 90)); // 3 months

        if (nextOilChange.isAfter(now)) {
          await scheduleServiceReminder(
            id: 'oil_${vehicle.id}'.hashCode.toString(),
            title: 'Oil Change Due Soon',
            body: 'Oil change due for ${vehicle.make} ${vehicle.model}',
            scheduledDate: nextOilChange.subtract(const Duration(days: 7)),
            payload: 'maintenance_oil_${vehicle.id}',
          );
        }
      }

      // Tire rotation reminder (every 6 months or 6000 miles)
      final lastTireRotation = _getLastServiceDate(vehicles, vehicle.id, ServiceType.tireRotation);
      if (lastTireRotation != null) {
        final nextTireRotation = lastTireRotation.add(const Duration(days: 180)); // 6 months

        if (nextTireRotation.isAfter(now)) {
          await scheduleServiceReminder(
            id: 'tires_${vehicle.id}'.hashCode.toString(),
            title: 'Tire Rotation Due',
            body: 'Tire rotation due for ${vehicle.make} ${vehicle.model}',
            scheduledDate: nextTireRotation.subtract(const Duration(days: 7)),
            payload: 'maintenance_tires_${vehicle.id}',
          );
        }
      }

      // Annual inspection reminder
      final lastInspection = _getLastServiceDate(vehicles, vehicle.id, ServiceType.inspection);
      if (lastInspection != null) {
        final nextInspection = lastInspection.add(const Duration(days: 365)); // 1 year

        if (nextInspection.isAfter(now)) {
          await scheduleServiceReminder(
            id: 'inspection_${vehicle.id}'.hashCode.toString(),
            title: 'Annual Inspection Due',
            body: 'Annual inspection due for ${vehicle.make} ${vehicle.model}',
            scheduledDate: nextInspection.subtract(const Duration(days: 30)),
            payload: 'maintenance_inspection_${vehicle.id}',
          );
        }
      }
    }
  }

  DateTime? _getLastServiceDate(List<Vehicle> vehicles, String vehicleId, ServiceType serviceType) {
    // This is a simplified implementation
    // In a real app, you'd query the services for this vehicle and service type
    // For now, we'll use a placeholder logic
    return DateTime.now().subtract(const Duration(days: 60)); // Placeholder
  }

  // Show immediate notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'immediate_notifications',
      'Immediate Notifications',
      channelDescription: 'Immediate notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  // Check notification permissions
  Future<bool> checkPermissions() async {
    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      return await androidImplementation.areNotificationsEnabled() ?? false;
    }

    final iosImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosImplementation != null) {
      return await iosImplementation.checkPermissionsStatus() != null;
    }

    return false;
  }

  // Request permissions again
  Future<bool> requestPermissions() async {
    await _requestPermissions();
    return await checkPermissions();
  }
}
