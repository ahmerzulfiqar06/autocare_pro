import 'package:autocare_pro/data/services/notification_service.dart';

class NotificationManager {
  final NotificationService _notificationService;

  NotificationManager({
    required NotificationService notificationService,
  }) : _notificationService = notificationService;

  Future<void> initializeSmartNotifications() async {
    // TODO: Implement when scheduling data is available
  }

  Future<void> cancelNotificationsForSchedule(String scheduleId) async {
    await _notificationService.cancelAllNotifications();
  }

  Future<void> showServiceLoggedNotification(String vehicleName, String serviceType) async {
    await _notificationService.showImmediateNotification(
      title: 'Service Logged Successfully',
      body: '$serviceType for $vehicleName has been recorded',
    );
  }

  Future<void> showVehicleAddedNotification(String vehicleName) async {
    await _notificationService.showImmediateNotification(
      title: 'Vehicle Added',
      body: '$vehicleName has been added to your garage',
    );
  }

  Future<void> showReminderNotification(String message) async {
    await _notificationService.showImmediateNotification(
      title: 'Maintenance Reminder',
      body: message,
    );
  }
}
