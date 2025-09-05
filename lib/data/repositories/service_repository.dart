import 'package:autocare_pro/data/models/service.dart';
import 'package:autocare_pro/data/models/service_schedule.dart';
import 'package:autocare_pro/data/services/database_service.dart';

class ServiceRepository {
  final DatabaseService _databaseService;

  ServiceRepository(this._databaseService);

  // Service operations
  Future<List<Service>> getServicesForVehicle(String vehicleId) async {
    try {
      return await _databaseService.getServicesForVehicle(vehicleId);
    } catch (e) {
      throw Exception('Failed to get services for vehicle: $e');
    }
  }

  Future<List<Service>> getAllServices() async {
    try {
      return await _databaseService.getAllServices();
    } catch (e) {
      throw Exception('Failed to get all services: $e');
    }
  }

  Future<Service?> getService(String id) async {
    try {
      final services = await getAllServices();
      return services.where((service) => service.id == id).firstOrNull;
    } catch (e) {
      throw Exception('Failed to get service: $e');
    }
  }

  Future<String> addService(Service service) async {
    try {
      _validateService(service);
      final id = await _databaseService.insertService(service);
      return id;
    } catch (e) {
      throw Exception('Failed to add service: $e');
    }
  }

  Future<void> updateService(Service service) async {
    try {
      _validateService(service);
      final rowsAffected = await _databaseService.updateService(service);
      if (rowsAffected == 0) {
        throw Exception('Service not found');
      }
    } catch (e) {
      throw Exception('Failed to update service: $e');
    }
  }

  Future<void> deleteService(String id) async {
    try {
      final rowsAffected = await _databaseService.deleteService(id);
      if (rowsAffected == 0) {
        throw Exception('Service not found');
      }
    } catch (e) {
      throw Exception('Failed to delete service: $e');
    }
  }

  // Service schedule operations
  Future<List<ServiceSchedule>> getSchedulesForVehicle(String vehicleId) async {
    try {
      return await _databaseService.getSchedulesForVehicle(vehicleId);
    } catch (e) {
      throw Exception('Failed to get service schedules for vehicle: $e');
    }
  }

  Future<List<ServiceSchedule>> getAllActiveSchedules() async {
    try {
      return await _databaseService.getAllActiveSchedules();
    } catch (e) {
      throw Exception('Failed to get active service schedules: $e');
    }
  }

  Future<String> addServiceSchedule(ServiceSchedule schedule) async {
    try {
      _validateServiceSchedule(schedule);
      final id = await _databaseService.insertServiceSchedule(schedule);
      return id;
    } catch (e) {
      throw Exception('Failed to add service schedule: $e');
    }
  }

  Future<void> updateServiceSchedule(ServiceSchedule schedule) async {
    try {
      _validateServiceSchedule(schedule);
      final rowsAffected = await _databaseService.updateServiceSchedule(schedule);
      if (rowsAffected == 0) {
        throw Exception('Service schedule not found');
      }
    } catch (e) {
      throw Exception('Failed to update service schedule: $e');
    }
  }

  Future<void> deleteServiceSchedule(String id) async {
    try {
      final rowsAffected = await _databaseService.deleteServiceSchedule(id);
      if (rowsAffected == 0) {
        throw Exception('Service schedule not found');
      }
    } catch (e) {
      throw Exception('Failed to delete service schedule: $e');
    }
  }

  // Get upcoming services (due within next 30 days)
  Future<List<ServiceSchedule>> getUpcomingServices({int daysAhead = 30}) async {
    try {
      final schedules = await getAllActiveSchedules();
      final now = DateTime.now();
      final futureDate = now.add(Duration(days: daysAhead));

      return schedules.where((schedule) {
        return schedule.nextServiceDate.isBefore(futureDate) &&
               schedule.nextServiceDate.isAfter(now.subtract(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      throw Exception('Failed to get upcoming services: $e');
    }
  }

  // Get overdue services
  Future<List<ServiceSchedule>> getOverdueServices() async {
    try {
      final schedules = await getAllActiveSchedules();
      final now = DateTime.now();

      return schedules.where((schedule) {
        return schedule.nextServiceDate.isBefore(now);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get overdue services: $e');
    }
  }

  // Get service statistics
  Future<Map<String, dynamic>> getServiceStatistics(String vehicleId) async {
    try {
      return await _databaseService.getServiceStats(vehicleId);
    } catch (e) {
      throw Exception('Failed to get service statistics: $e');
    }
  }

  // Get total service cost for all vehicles
  Future<double> getTotalServiceCost() async {
    try {
      return await _databaseService.getTotalServiceCostAll();
    } catch (e) {
      throw Exception('Failed to get total service cost: $e');
    }
  }

  // Update service schedule after service completion
  Future<void> updateScheduleAfterService(
    String scheduleId,
    DateTime serviceDate,
    int serviceMileage,
  ) async {
    try {
      final schedule = await getAllActiveSchedules()
          .then((schedules) => schedules.where((s) => s.id == scheduleId).firstOrNull);

      if (schedule == null) {
        throw Exception('Service schedule not found');
      }

      final updatedSchedule = ServiceSchedule(
        id: schedule.id,
        vehicleId: schedule.vehicleId,
        serviceType: schedule.serviceType,
        intervalMiles: schedule.intervalMiles,
        intervalMonths: schedule.intervalMonths,
        lastServiceDate: serviceDate,
        lastServiceMileage: serviceMileage,
        isActive: schedule.isActive,
        notes: schedule.notes,
        createdAt: schedule.createdAt,
        updatedAt: DateTime.now(),
      );

      await updateServiceSchedule(updatedSchedule);
    } catch (e) {
      throw Exception('Failed to update schedule after service: $e');
    }
  }

  // Validate service data
  void _validateService(Service service) {
    if (service.cost < 0) {
      throw Exception('Service cost cannot be negative');
    }
    if (service.mileageAtService < 0) {
      throw Exception('Mileage cannot be negative');
    }
    if (service.serviceDate.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      throw Exception('Service date cannot be in the future');
    }
  }

  // Validate service schedule data
  void _validateServiceSchedule(ServiceSchedule schedule) {
    if (schedule.intervalMiles < 0) {
      throw Exception('Interval miles cannot be negative');
    }
    if (schedule.intervalMonths < 0) {
      throw Exception('Interval months cannot be negative');
    }
    if (schedule.intervalMiles == 0 && schedule.intervalMonths == 0) {
      throw Exception('At least one interval (miles or months) must be set');
    }
    if (schedule.lastServiceMileage < 0) {
      throw Exception('Last service mileage cannot be negative');
    }
  }
}

// Extension for firstOrNull
extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
