import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:autocare_pro/data/models/vehicle.dart';
import 'package:autocare_pro/data/models/service.dart';

// Firebase configuration for AutoCare Pro
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  // Authentication Methods
  Future<User?> signInAnonymously() async {
    try {
      final result = await _auth.signInAnonymously();
      return result.user;
    } catch (e) {
      throw Exception('Failed to sign in anonymously: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
  String? get userId => _auth.currentUser?.uid;

  // Vehicle CRUD Operations
  Future<void> saveVehicle(Vehicle vehicle) async {
    if (userId == null) throw Exception('User not authenticated');

    try {
      final vehicleData = vehicle.toMap();
      vehicleData['userId'] = userId;
      vehicleData['syncedAt'] = DateTime.now().toIso8601String();

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .doc(vehicle.id)
          .set(vehicleData);
    } catch (e) {
      throw Exception('Failed to save vehicle: $e');
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    if (userId == null) throw Exception('User not authenticated');

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .doc(vehicleId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete vehicle: $e');
    }
  }

  Future<List<Vehicle>> getVehicles() async {
    if (userId == null) throw Exception('User not authenticated');

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .orderBy('updatedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Vehicle.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to get vehicles: $e');
    }
  }

  // Service CRUD Operations
  Future<void> saveService(Service service) async {
    if (userId == null) throw Exception('User not authenticated');

    try {
      final serviceData = service.toMap();
      serviceData['userId'] = userId;
      serviceData['syncedAt'] = DateTime.now().toIso8601String();

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('services')
          .doc(service.id)
          .set(serviceData);
    } catch (e) {
      throw Exception('Failed to save service: $e');
    }
  }

  Future<void> deleteService(String serviceId) async {
    if (userId == null) throw Exception('User not authenticated');

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('services')
          .doc(serviceId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete service: $e');
    }
  }

  Future<List<Service>> getServices() async {
    if (userId == null) throw Exception('User not authenticated');

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('services')
          .orderBy('serviceDate', descending: true)
          .get();

      return snapshot.docs.map((doc) => Service.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to get services: $e');
    }
  }

  Future<List<Service>> getServicesForVehicle(String vehicleId) async {
    if (userId == null) throw Exception('User not authenticated');

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('services')
          .where('vehicleId', isEqualTo: vehicleId)
          .orderBy('serviceDate', descending: true)
          .get();

      return snapshot.docs.map((doc) => Service.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to get services for vehicle: $e');
    }
  }

  // Sync Methods
  Future<void> syncLocalToCloud(List<Vehicle> vehicles, List<Service> services) async {
    if (userId == null) throw Exception('User not authenticated');

    try {
      // Sync vehicles
      final vehicleBatch = _firestore.batch();
      for (final vehicle in vehicles) {
        final vehicleData = vehicle.toMap();
        vehicleData['userId'] = userId;
        vehicleData['syncedAt'] = DateTime.now().toIso8601String();

        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('vehicles')
            .doc(vehicle.id);

        vehicleBatch.set(docRef, vehicleData);
      }
      await vehicleBatch.commit();

      // Sync services
      final serviceBatch = _firestore.batch();
      for (final service in services) {
        final serviceData = service.toMap();
        serviceData['userId'] = userId;
        serviceData['syncedAt'] = DateTime.now().toIso8601String();

        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('services')
            .doc(service.id);

        serviceBatch.set(docRef, serviceData);
      }
      await serviceBatch.commit();

    } catch (e) {
      throw Exception('Failed to sync data to cloud: $e');
    }
  }

  Future<Map<String, dynamic>> syncCloudToLocal() async {
    if (userId == null) throw Exception('User not authenticated');

    try {
      // Get cloud vehicles
      final vehicleSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .get();

      // Get cloud services
      final serviceSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('services')
          .get();

      final vehicles = vehicleSnapshot.docs.map((doc) => Vehicle.fromMap(doc.data())).toList();
      final services = serviceSnapshot.docs.map((doc) => Service.fromMap(doc.data())).toList();

      return {
        'vehicles': vehicles,
        'services': services,
      };

    } catch (e) {
      throw Exception('Failed to sync data from cloud: $e');
    }
  }

  // Backup and Restore Methods
  Future<String> createBackup() async {
    if (userId == null) throw Exception('User not authenticated');

    try {
      final vehicles = await getVehicles();
      final services = await getServices();

      final backupData = {
        'userId': userId,
        'backupDate': DateTime.now().toIso8601String(),
        'vehicles': vehicles.map((v) => v.toMap()).toList(),
        'services': services.map((s) => s.toMap()).toList(),
      };

      // Save backup to user's backups collection
      final backupId = DateTime.now().millisecondsSinceEpoch.toString();
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('backups')
          .doc(backupId)
          .set(backupData);

      return backupId;

    } catch (e) {
      throw Exception('Failed to create backup: $e');
    }
  }

  Future<Map<String, dynamic>> restoreBackup(String backupId) async {
    if (userId == null) throw Exception('User not authenticated');

    try {
      final backupDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('backups')
          .doc(backupId)
          .get();

      if (!backupDoc.exists) {
        throw Exception('Backup not found');
      }

      final backupData = backupDoc.data()!;
      final vehicles = (backupData['vehicles'] as List<dynamic>)
          .map((v) => Vehicle.fromMap(v as Map<String, dynamic>))
          .toList();
      final services = (backupData['services'] as List<dynamic>)
          .map((s) => Service.fromMap(s as Map<String, dynamic>))
          .toList();

      return {
        'vehicles': vehicles,
        'services': services,
      };

    } catch (e) {
      throw Exception('Failed to restore backup: $e');
    }
  }

  // Analytics Methods
  Future<Map<String, dynamic>> getAnalyticsData() async {
    if (userId == null) throw Exception('User not authenticated');

    try {
      final services = await getServices();
      final vehicles = await getVehicles();

      // Calculate analytics
      final totalSpent = services.fold<double>(0.0, (sum, service) => sum + service.cost);
      final avgCostPerService = services.isNotEmpty ? totalSpent / services.length : 0.0;

      // Group services by type
      final serviceTypeCount = <String, int>{};
      for (final service in services) {
        serviceTypeCount[service.serviceType.displayName] =
            (serviceTypeCount[service.serviceType.displayName] ?? 0) + 1;
      }

      // Group services by month
      final monthlyData = <String, double>{};
      for (final service in services) {
        final monthKey = '${service.serviceDate.year}-${service.serviceDate.month.toString().padLeft(2, '0')}';
        monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + service.cost;
      }

      return {
        'totalVehicles': vehicles.length,
        'totalServices': services.length,
        'totalSpent': totalSpent,
        'avgCostPerService': avgCostPerService,
        'serviceTypeCount': serviceTypeCount,
        'monthlyData': monthlyData,
      };

    } catch (e) {
      throw Exception('Failed to get analytics data: $e');
    }
  }

  // Real-time listeners
  Stream<List<Vehicle>> watchVehicles() {
    if (userId == null) throw Exception('User not authenticated');

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('vehicles')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Vehicle.fromMap(doc.data())).toList());
  }

  Stream<List<Service>> watchServices() {
    if (userId == null) throw Exception('User not authenticated');

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('services')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Service.fromMap(doc.data())).toList());
  }
}
