import 'package:autocare_pro/data/models/service_schedule.dart';
import 'package:autocare_pro/data/models/vehicle.dart';
import 'package:autocare_pro/data/repositories/service_repository.dart';
import 'package:autocare_pro/data/repositories/vehicle_repository.dart';
import 'package:autocare_pro/data/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationManager {
  final NotificationService _notificationService;
  final ServiceRepository _serviceRepository;
  final VehicleRepository _vehicleRepository;

  NotificationManager({
    required NotificationService notificationService,
    required ServiceRepository serviceRepository,
    required VehicleRepository vehicleRepository,
  })  : _notificationService = notificationService,
        _serviceRepository = serviceRepository,
        _vehicleRepository = vehicleRepository;

  // Initialize and schedule all smart notifications
  Future<void> initializeSmartNotifications() async {
    try {
      // Get all active schedules and vehicles
      final schedules = await _serviceRepository.getAllServiceSchedules();
      final vehicles = await _vehicleRepository.getAllVehicles();

      // Schedule smart reminders
      await _notificationService.scheduleSmartServiceReminders(schedules, vehicles);

      // Schedule weekly summary notification
      await _scheduleWeeklySummary();

    } catch (e) {
      // Handle initialization errors gracefully
      print('Failed to initialize smart notifications: $e');
    }
  }

  // Schedule weekly maintenance summary notification
  Future<void> _scheduleWeeklySummary() async {
    await _notificationService.scheduleRecurringNotification(
      id: 'weekly_summary',
      title: 'Weekly Maintenance Summary',
      body: 'Check your vehicle maintenance status and upcoming services',
      interval: RepeatInterval.weekly,
      time: const TimeOfDay(hour: 9, minute: 0), // Every Sunday at 9 AM
      payload: 'weekly_summary',
    );
  }

  // Update notifications when schedules change
  Future<void> updateNotificationsForSchedule(ServiceSchedule schedule) async {
    try {
      final vehicle = await _vehicleRepository.getVehicleById(schedule.vehicleId);
      if (vehicle != null) {
        await _notificationService.scheduleSmartServiceReminders([schedule], [vehicle]);
      }
    } catch (e) {
      print('Failed to update notifications for schedule: $e');
    }
  }

  // Cancel notifications for a specific schedule
  Future<void> cancelNotificationsForSchedule(String scheduleId) async {
    // This would require tracking notification IDs for each schedule
    // For now, we'll cancel all and reschedule
    await _notificationService.cancelAllNotifications();
    await initializeSmartNotifications();
  }

  // Show immediate feedback notifications
  Future<void> showServiceLoggedNotification(String vehicleName, String serviceType) async {
    await _notificationService.showImmediateNotification(
      title: 'Service Logged Successfully',
      body: '$serviceType for $vehicleName has been recorded',
      importance: NotificationImportance.high,
    );
  }

  Future<void> showVehicleAddedNotification(String vehicleName) async {
    await _notificationService.showImmediateNotification(
      title: 'Vehicle Added',
      body: '$vehicleName has been added to your garage',
      importance: NotificationImportance.defaultImportance,
    );
  }

  Future<void> showReminderNotification(String message) async {
    await _notificationService.showImmediateNotification(
      title: 'Maintenance Reminder',
      body: message,
      importance: NotificationImportance.high,
    );
  }
}
