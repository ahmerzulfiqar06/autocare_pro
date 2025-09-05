import 'package:autocare_pro/data/models/vehicle.dart';
import 'package:autocare_pro/data/services/database_service.dart';

class VehicleRepository {
  final DatabaseService _databaseService;

  VehicleRepository(this._databaseService);

  // Get all vehicles
  Future<List<Vehicle>> getAllVehicles() async {
    try {
      return await _databaseService.getAllVehicles();
    } catch (e) {
      throw Exception('Failed to get vehicles: $e');
    }
  }

  // Get vehicle by ID
  Future<Vehicle?> getVehicle(String id) async {
    try {
      return await _databaseService.getVehicle(id);
    } catch (e) {
      throw Exception('Failed to get vehicle: $e');
    }
  }

  // Add new vehicle
  Future<String> addVehicle(Vehicle vehicle) async {
    try {
      // Validate vehicle data
      _validateVehicle(vehicle);

      final id = await _databaseService.insertVehicle(vehicle);
      return id;
    } catch (e) {
      throw Exception('Failed to add vehicle: $e');
    }
  }

  // Update existing vehicle
  Future<void> updateVehicle(Vehicle vehicle) async {
    try {
      // Validate vehicle data
      _validateVehicle(vehicle);

      final rowsAffected = await _databaseService.updateVehicle(vehicle);
      if (rowsAffected == 0) {
        throw Exception('Vehicle not found');
      }
    } catch (e) {
      throw Exception('Failed to update vehicle: $e');
    }
  }

  // Delete vehicle
  Future<void> deleteVehicle(String id) async {
    try {
      final rowsAffected = await _databaseService.deleteVehicle(id);
      if (rowsAffected == 0) {
        throw Exception('Vehicle not found');
      }
    } catch (e) {
      throw Exception('Failed to delete vehicle: $e');
    }
  }

  // Update vehicle mileage
  Future<void> updateVehicleMileage(String vehicleId, int newMileage) async {
    try {
      final vehicle = await getVehicle(vehicleId);
      if (vehicle == null) {
        throw Exception('Vehicle not found');
      }

      if (newMileage < vehicle.currentMileage) {
        throw Exception('New mileage cannot be less than current mileage');
      }

      final updatedVehicle = vehicle.copyWith(
        currentMileage: newMileage,
        updatedAt: DateTime.now(),
      );

      await updateVehicle(updatedVehicle);
    } catch (e) {
      throw Exception('Failed to update vehicle mileage: $e');
    }
  }

  // Get vehicles by status
  Future<List<Vehicle>> getVehiclesByStatus(VehicleStatus status) async {
    try {
      final allVehicles = await getAllVehicles();
      return allVehicles.where((vehicle) => vehicle.status == status).toList();
    } catch (e) {
      throw Exception('Failed to get vehicles by status: $e');
    }
  }

  // Search vehicles by make or model
  Future<List<Vehicle>> searchVehicles(String query) async {
    try {
      final allVehicles = await getAllVehicles();
      final lowercaseQuery = query.toLowerCase();
      return allVehicles.where((vehicle) {
        return vehicle.make.toLowerCase().contains(lowercaseQuery) ||
               vehicle.model.toLowerCase().contains(lowercaseQuery) ||
               vehicle.displayName.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search vehicles: $e');
    }
  }

  // Get vehicle statistics
  Future<Map<String, dynamic>> getVehicleStats(String vehicleId) async {
    try {
      return await _databaseService.getServiceStats(vehicleId);
    } catch (e) {
      throw Exception('Failed to get vehicle stats: $e');
    }
  }

  // Validate vehicle data
  void _validateVehicle(Vehicle vehicle) {
    if (vehicle.make.trim().isEmpty) {
      throw Exception('Vehicle make is required');
    }
    if (vehicle.model.trim().isEmpty) {
      throw Exception('Vehicle model is required');
    }
    if (vehicle.year < 1900 || vehicle.year > DateTime.now().year + 1) {
      throw Exception('Invalid vehicle year');
    }
    if (vehicle.currentMileage < 0) {
      throw Exception('Mileage cannot be negative');
    }
    if (vehicle.purchaseDate != null &&
        vehicle.purchaseDate!.isAfter(DateTime.now())) {
      throw Exception('Purchase date cannot be in the future');
    }
  }
}
