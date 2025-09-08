import 'package:autocare_pro/data/models/service_schedule.dart';
import 'package:autocare_pro/data/services/database_service.dart';

class ServiceScheduleRepository {
  final DatabaseService _databaseService;

  ServiceScheduleRepository(this._databaseService);

  // Get all active schedules for a vehicle
  Future<List<ServiceSchedule>> getSchedulesForVehicle(String vehicleId) async {
    return await _databaseService.getSchedulesForVehicle(vehicleId);
  }

  // Get all active schedules
  Future<List<ServiceSchedule>> getAllActiveSchedules() async {
    return await _databaseService.getAllActiveSchedules();
  }

  // Add new schedule
  Future<String> addSchedule(ServiceSchedule schedule) async {
    return await _databaseService.insertServiceSchedule(schedule);
  }

  // Update existing schedule
  Future<bool> updateSchedule(ServiceSchedule schedule) async {
    final result = await _databaseService.updateServiceSchedule(schedule);
    return result > 0;
  }

  // Delete schedule
  Future<bool> deleteSchedule(String scheduleId) async {
    final result = await _databaseService.deleteServiceSchedule(scheduleId);
    return result > 0;
  }

  // Toggle schedule active/inactive
  Future<bool> toggleScheduleStatus(String scheduleId, bool isActive) async {
    // This would require getting the schedule first, updating it, then saving
    // For now, we'll implement a simple version
    final schedules = await getAllActiveSchedules();
    final schedule = schedules.firstWhere(
      (s) => s.id == scheduleId,
      orElse: () => throw Exception('Schedule not found'),
    );

    final updatedSchedule = schedule.copyWith(isActive: isActive);
    return await updateSchedule(updatedSchedule);
  }

  // Get schedules that are due soon (within next 30 days)
  Future<List<ServiceSchedule>> getDueSchedules({int daysAhead = 30}) async {
    final allSchedules = await getAllActiveSchedules();
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: daysAhead));

    return allSchedules.where((schedule) {
      return schedule.nextServiceDate.isBefore(futureDate) ||
             (schedule.nextServiceMileage != null && schedule.nextServiceMileage! <= 1000); // Within 1000 miles
    }).toList();
  }

  // Update schedule after service is completed
  Future<bool> updateScheduleAfterService(
    String scheduleId,
    DateTime serviceDate,
    int? mileage,
  ) async {
    final schedules = await getAllActiveSchedules();
    final schedule = schedules.firstWhere(
      (s) => s.id == scheduleId,
      orElse: () => throw Exception('Schedule not found'),
    );

    // Calculate next service date based on frequency
    DateTime nextServiceDate;
    int? nextServiceMileage;

    switch (schedule.frequency) {
      case ScheduleFrequency.monthly:
        nextServiceDate = serviceDate.add(const Duration(days: 30));
        break;
      case ScheduleFrequency.quarterly:
        nextServiceDate = serviceDate.add(const Duration(days: 90));
        break;
      case ScheduleFrequency.semiAnnually:
        nextServiceDate = serviceDate.add(const Duration(days: 180));
        break;
      case ScheduleFrequency.annually:
        nextServiceDate = serviceDate.add(const Duration(days: 365));
        break;
      case ScheduleFrequency.custom:
        if (schedule.monthsInterval != null) {
          nextServiceDate = serviceDate.add(Duration(days: schedule.monthsInterval! * 30));
        } else {
          nextServiceDate = serviceDate.add(const Duration(days: 90));
        }
        break;
      case ScheduleFrequency.mileage:
        nextServiceDate = serviceDate.add(const Duration(days: 90)); // Fallback
        if (schedule.mileageInterval != null && mileage != null) {
          nextServiceMileage = mileage + schedule.mileageInterval!;
        }
        break;
    }

    final updatedSchedule = schedule.copyWith(
      lastServiceDate: serviceDate,
      lastServiceMileage: mileage,
      nextServiceDate: nextServiceDate,
      nextServiceMileage: nextServiceMileage,
      updatedAt: DateTime.now(),
    );

    return await updateSchedule(updatedSchedule);
  }
}
