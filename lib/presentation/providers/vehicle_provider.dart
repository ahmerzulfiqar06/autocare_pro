import 'package:flutter/material.dart';
import 'package:autocare_pro/data/models/vehicle.dart';
import 'package:autocare_pro/data/repositories/vehicle_repository.dart';

class VehicleProvider extends ChangeNotifier {
  final VehicleRepository _vehicleRepository;

  VehicleProvider(this._vehicleRepository);

  List<Vehicle> _vehicles = [];
  bool _isLoading = false;
  String? _error;

  List<Vehicle> get vehicles => _vehicles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all vehicles
  Future<void> loadVehicles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _vehicles = await _vehicleRepository.getAllVehicles();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new vehicle
  Future<bool> addVehicle(Vehicle vehicle) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _vehicleRepository.addVehicle(vehicle);
      await loadVehicles(); // Reload list
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update vehicle
  Future<bool> updateVehicle(Vehicle vehicle) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _vehicleRepository.updateVehicle(vehicle);
      await loadVehicles(); // Reload list
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete vehicle
  Future<bool> deleteVehicle(String vehicleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _vehicleRepository.deleteVehicle(vehicleId);
      await loadVehicles(); // Reload list
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update vehicle mileage
  Future<bool> updateVehicleMileage(String vehicleId, int newMileage) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _vehicleRepository.updateVehicleMileage(vehicleId, newMileage);
      await loadVehicles(); // Reload list
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get vehicle by ID
  Vehicle? getVehicleById(String id) {
    try {
      return _vehicles.where((vehicle) => vehicle.id == id).firstOrNull;
    } catch (e) {
      return null;
    }
  }

  // Get vehicles by status
  List<Vehicle> getVehiclesByStatus(VehicleStatus status) {
    return _vehicles.where((vehicle) => vehicle.status == status).toList();
  }

  // Search vehicles
  List<Vehicle> searchVehicles(String query) {
    if (query.isEmpty) return _vehicles;

    final lowercaseQuery = query.toLowerCase();
    return _vehicles.where((vehicle) {
      return vehicle.make.toLowerCase().contains(lowercaseQuery) ||
             vehicle.model.toLowerCase().contains(lowercaseQuery) ||
             vehicle.displayName.toLowerCase().contains(lowercaseQuery) ||
             (vehicle.licensePlate?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             (vehicle.vin?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  // Get vehicle statistics
  Future<Map<String, dynamic>?> getVehicleStats(String vehicleId) async {
    try {
      return await _vehicleRepository.getVehicleStats(vehicleId);
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

  // Get active vehicles count
  int get activeVehiclesCount {
    return _vehicles.where((vehicle) => vehicle.status == VehicleStatus.active).length;
  }

  // Get total vehicles count
  int get totalVehiclesCount => _vehicles.length;

  // Get vehicles by make
  Map<String, int> get vehiclesByMake {
    final makeCount = <String, int>{};
    for (final vehicle in _vehicles) {
      makeCount[vehicle.make] = (makeCount[vehicle.make] ?? 0) + 1;
    }
    return makeCount;
  }

  // Get recent vehicles (added in last 30 days)
  List<Vehicle> get recentVehicles {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return _vehicles
        .where((vehicle) => vehicle.createdAt.isAfter(thirtyDaysAgo))
        .toList();
  }

  // Clear all data
  Future<void> clearAllData() async {
    _vehicles.clear();
    _error = null;
    notifyListeners();
  }
}

// Extension for firstOrNull
extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
