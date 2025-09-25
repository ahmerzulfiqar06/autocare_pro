import 'package:flutter/material.dart';
import 'package:autocare_pro/data/models/service.dart';
import 'package:autocare_pro/data/models/service_schedule.dart';
import 'package:autocare_pro/data/repositories/service_repository.dart';

class ServiceProvider extends ChangeNotifier {
  final ServiceRepository _serviceRepository;

  ServiceProvider(this._serviceRepository);

  List<Service> _services = [];
  List<ServiceSchedule> _serviceSchedules = [];
  bool _isLoading = false;
  String? _error;

  List<Service> get services => _services;
  List<Service> get allServices => _services;
  List<ServiceSchedule> get serviceSchedules => _serviceSchedules;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalServicesCount => _services.length;

  // Load services for a specific vehicle
  Future<void> loadServicesForVehicle(String vehicleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _services = await _serviceRepository.getServicesForVehicle(vehicleId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load all services
  Future<void> loadAllServices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _services = await _serviceRepository.getAllServices();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load service schedules for a vehicle
  Future<void> loadServiceSchedulesForVehicle(String vehicleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _serviceSchedules = await _serviceRepository.getSchedulesForVehicle(vehicleId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load all active service schedules
  Future<void> loadAllActiveSchedules() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _serviceSchedules = await _serviceRepository.getAllActiveSchedules();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new service
  Future<bool> addService(Service service) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _serviceRepository.addService(service);
      await loadServicesForVehicle(service.vehicleId); // Reload services
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update service
  Future<bool> updateService(Service service) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _serviceRepository.updateService(service);
      await loadServicesForVehicle(service.vehicleId); // Reload services
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete service (single parameter version)
  Future<bool> deleteService(String serviceId) async {
    // Find the service to get the vehicle ID
    final service = getServiceById(serviceId);
    if (service == null) return false;

    return deleteServiceWithVehicleId(serviceId, service.vehicleId);
  }

  // Delete service (with vehicle ID)
  Future<bool> deleteServiceWithVehicleId(String serviceId, String vehicleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _serviceRepository.deleteService(serviceId);
      await loadServicesForVehicle(vehicleId); // Reload services
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Add service schedule
  Future<bool> addServiceSchedule(ServiceSchedule schedule) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _serviceRepository.addServiceSchedule(schedule);
      await loadServiceSchedulesForVehicle(schedule.vehicleId); // Reload schedules
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update service schedule
  Future<bool> updateServiceSchedule(ServiceSchedule schedule) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _serviceRepository.updateServiceSchedule(schedule);
      await loadServiceSchedulesForVehicle(schedule.vehicleId); // Reload schedules
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete service schedule
  Future<bool> deleteServiceSchedule(String scheduleId, String vehicleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _serviceRepository.deleteServiceSchedule(scheduleId);
      await loadServiceSchedulesForVehicle(vehicleId); // Reload schedules
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get upcoming services
  Future<List<ServiceSchedule>> getUpcomingServices({int daysAhead = 30}) async {
    try {
      return await _serviceRepository.getUpcomingServices(daysAhead: daysAhead);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Get overdue services
  Future<List<ServiceSchedule>> getOverdueServices() async {
    try {
      return await _serviceRepository.getOverdueServices();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Update schedule after service completion
  Future<bool> updateScheduleAfterService(
    String scheduleId,
    DateTime serviceDate,
    int serviceMileage,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _serviceRepository.updateScheduleAfterService(
        scheduleId,
        serviceDate,
        serviceMileage,
      );
      await loadAllActiveSchedules(); // Reload all schedules
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get service by ID
  Service? getServiceById(String id) {
    try {
      return _services.where((service) => service.id == id).firstOrNull;
    } catch (e) {
      return null;
    }
  }

  // Get services for vehicle (alias for existing method)
  List<Service> getServicesForVehicle(String vehicleId) {
    return _services.where((service) => service.vehicleId == vehicleId).toList();
  }

  // Get services for vehicle (future version)
  Future<List<Service>> getServicesForVehicleFuture(String vehicleId) async {
    // Load services if not already loaded
    if (_services.isEmpty) {
      await loadServicesForVehicle(vehicleId);
    }
    return getServicesForVehicle(vehicleId);
  }

  // Clear all data
  Future<void> clearAllData() async {
    _services.clear();
    _serviceSchedules.clear();
    _error = null;
    notifyListeners();
  }

  // Get schedule by ID
  ServiceSchedule? getScheduleById(String id) {
    try {
      return _serviceSchedules.where((schedule) => schedule.id == id).firstOrNull;
    } catch (e) {
      return null;
    }
  }

  // Get services by type
  List<Service> getServicesByType(ServiceType type) {
    return _services.where((service) => service.serviceType == type).toList();
  }

  // Get total service cost for vehicle
  Future<double> getTotalServiceCost(String vehicleId) async {
    try {
      final stats = await _serviceRepository.getServiceStatistics(vehicleId);
      return stats['totalCost'] ?? 0.0;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return 0.0;
    }
  }

  // Get total service cost for all vehicles
  Future<double> getTotalServiceCostAll() async {
    try {
      return await _serviceRepository.getTotalServiceCost();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return 0.0;
    }
  }

  // Get all services as Future (for charts)
  Future<List<Service>> getAllServicesFuture() async {
    try {
      return await _serviceRepository.getAllServices();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Get service statistics
  Future<Map<String, dynamic>?> getServiceStatistics(String vehicleId) async {
    try {
      return await _serviceRepository.getServiceStatistics(vehicleId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get services count
  int get servicesCount => _services.length;

  // Get schedules count
  int get schedulesCount => _serviceSchedules.length;

  // Get upcoming services count
  Future<int> getUpcomingServicesCount({int daysAhead = 30}) async {
    final upcoming = await getUpcomingServices(daysAhead: daysAhead);
    return upcoming.length;
  }

  // Get overdue services count
  Future<int> getOverdueServicesCount() async {
    final overdue = await getOverdueServices();
    return overdue.length;
  }

  // Get services by month (for charts)
  Map<String, int> getServicesByMonth() {
    final monthlyCount = <String, int>{};
    for (final service in _services) {
      final monthKey = '${service.serviceDate.year}-${service.serviceDate.month.toString().padLeft(2, '0')}';
      monthlyCount[monthKey] = (monthlyCount[monthKey] ?? 0) + 1;
    }
    return monthlyCount;
  }

  // Get average service cost
  double get averageServiceCost {
    if (_services.isEmpty) return 0.0;
    final total = _services.fold<double>(0, (sum, service) => sum + service.cost);
    return total / _services.length;
  }
}

