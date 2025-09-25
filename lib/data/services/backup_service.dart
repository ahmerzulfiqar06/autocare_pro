import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:autocare_pro/data/models/vehicle.dart';
import 'package:autocare_pro/data/models/service.dart';
import 'package:autocare_pro/data/models/service_schedule.dart';
import 'package:autocare_pro/data/repositories/vehicle_repository.dart';
import 'package:autocare_pro/data/repositories/service_repository.dart';

class BackupService {
  static const String _backupPrefix = 'autocare_backup_';
  static const String _backupExtension = '.json';
  static const String _backupVersion = '1.0';

  // Create a complete backup of all data
  Future<File> createFullBackup({
    required List<Vehicle> vehicles,
    required List<Service> services,
    required List<ServiceSchedule> schedules,
    String backupName = 'full_backup',
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final fileName = '$_backupPrefix$backupName$_backupExtension';
    final file = File('${directory.path}/$fileName');

    final backupData = {
      'version': _backupVersion,
      'timestamp': timestamp,
      'data': {
        'vehicles': vehicles.map((v) => v.toMap()).toList(),
        'services': services.map((s) => s.toMap()).toList(),
        'schedules': schedules.map((s) => s.toMap()).toList(),
      },
      'metadata': {
        'totalVehicles': vehicles.length,
        'totalServices': services.length,
        'totalSchedules': schedules.length,
        'appVersion': _backupVersion,
      },
    };

    final jsonString = JsonEncoder.withIndent('  ').convert(backupData);
    await file.writeAsString(jsonString);

    return file;
  }

  // Create a selective backup based on criteria
  Future<File> createSelectiveBackup({
    required List<Vehicle> vehicles,
    required List<Service> services,
    required List<ServiceSchedule> schedules,
    bool includeVehicles = true,
    bool includeServices = true,
    bool includeSchedules = true,
    DateTime? fromDate,
    DateTime? toDate,
    String backupName = 'selective_backup',
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final fileName = '$_backupPrefix$backupName$_backupExtension';
    final file = File('${directory.path}/$fileName');

    // Filter data based on criteria
    final filteredVehicles = includeVehicles ? vehicles : [];
    final filteredServices = includeServices ? _filterServicesByDate(services, fromDate, toDate) : [];
    final filteredSchedules = includeSchedules ? schedules : [];

    final backupData = {
      'version': _backupVersion,
      'timestamp': timestamp,
      'criteria': {
        'includeVehicles': includeVehicles,
        'includeServices': includeServices,
        'includeSchedules': includeSchedules,
        'fromDate': fromDate?.toIso8601String(),
        'toDate': toDate?.toIso8601String(),
      },
      'data': {
        'vehicles': filteredVehicles.map((v) => v.toMap()).toList(),
        'services': filteredServices.map((s) => s.toMap()).toList(),
        'schedules': filteredSchedules.map((s) => s.toMap()).toList(),
      },
      'metadata': {
        'totalVehicles': filteredVehicles.length,
        'totalServices': filteredServices.length,
        'totalSchedules': filteredSchedules.length,
        'appVersion': _backupVersion,
      },
    };

    final jsonString = JsonEncoder.withIndent('  ').convert(backupData);
    await file.writeAsString(jsonString);

    return file;
  }

  // Restore from backup file
  Future<BackupRestoreResult> restoreFromBackup(File backupFile) async {
    try {
      final jsonString = await backupFile.readAsString();
      final backupData = json.decode(jsonString) as Map<String, dynamic>;

      // Validate backup version
      final version = backupData['version'] as String?;
      if (version != _backupVersion) {
        return BackupRestoreResult(
          success: false,
          message: 'Backup version $version is not supported. Expected version $_backupVersion.',
          data: null,
        );
      }

      final data = backupData['data'] as Map<String, dynamic>;
      final metadata = backupData['metadata'] as Map<String, dynamic>;

      final vehiclesData = data['vehicles'] as List<dynamic>? ?? [];
      final servicesData = data['services'] as List<dynamic>? ?? [];
      final schedulesData = data['schedules'] as List<dynamic>? ?? [];

      final vehicles = vehiclesData.map((v) => Vehicle.fromMap(v as Map<String, dynamic>)).toList();
      final services = servicesData.map((s) => Service.fromMap(s as Map<String, dynamic>)).toList();
      final schedules = schedulesData.map((s) => ServiceSchedule.fromMap(s as Map<String, dynamic>)).toList();

      return BackupRestoreResult(
        success: true,
        message: 'Backup restored successfully',
        data: BackupData(
          vehicles: vehicles,
          services: services,
          schedules: schedules,
          metadata: metadata,
        ),
      );
    } catch (e) {
      return BackupRestoreResult(
        success: false,
        message: 'Failed to restore backup: $e',
        data: null,
      );
    }
  }

  // Get list of available backups
  Future<List<File>> getAvailableBackups() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = await directory.list().toList();

    return files
        .whereType<File>()
        .where((file) => file.path.contains(_backupPrefix) && file.path.endsWith(_backupExtension))
        .toList();
  }

  // Delete a backup file
  Future<bool> deleteBackup(File backupFile) async {
    try {
      await backupFile.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Validate backup file integrity
  Future<bool> validateBackup(File backupFile) async {
    try {
      final jsonString = await backupFile.readAsString();
      final backupData = json.decode(jsonString) as Map<String, dynamic>;

      // Check required fields
      if (!backupData.containsKey('version') ||
          !backupData.containsKey('timestamp') ||
          !backupData.containsKey('data')) {
        return false;
      }

      final data = backupData['data'] as Map<String, dynamic>;

      // Check data structure
      if (!data.containsKey('vehicles') ||
          !data.containsKey('services') ||
          !data.containsKey('schedules')) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Share backup file
  Future<void> shareBackup(File backupFile, String backupName) async {
    try {
      await Share.shareXFiles(
        [XFile(backupFile.path)],
        text: 'AutoCare Pro - Backup: $backupName',
        subject: 'Vehicle Maintenance Backup',
      );
    } catch (e) {
      throw Exception('Failed to share backup: $e');
    }
  }

  // Create automatic backup
  Future<File> createAutomaticBackup({
    required List<Vehicle> vehicles,
    required List<Service> services,
    required List<ServiceSchedule> schedules,
  }) async {
    final timestamp = DateTime.now().toIso8601String().split('T')[0]; // Date only
    return createFullBackup(
      vehicles: vehicles,
      services: services,
      schedules: schedules,
      backupName: 'auto_$timestamp',
    );
  }

  // Clean up old backups (keep only last 10)
  Future<void> cleanupOldBackups({int keepLast = 10}) async {
    final backups = await getAvailableBackups();

    if (backups.length <= keepLast) return;

    // Sort by creation date (newest first)
    backups.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

    // Delete older backups
    final backupsToDelete = backups.sublist(keepLast);
    for (final backup in backupsToDelete) {
      try {
        await backup.delete();
      } catch (e) {
        // Ignore deletion errors
      }
    }
  }

  // Filter services by date range
  List<Service> _filterServicesByDate(List<Service> services, DateTime? fromDate, DateTime? toDate) {
    return services.where((service) {
      if (fromDate != null && service.serviceDate.isBefore(fromDate)) {
        return false;
      }
      if (toDate != null && service.serviceDate.isAfter(toDate)) {
        return false;
      }
      return true;
    }).toList();
  }

  // Get backup file info
  Future<BackupFileInfo> getBackupFileInfo(File backupFile) async {
    try {
      final isValid = await validateBackup(backupFile);
      final lastModified = backupFile.lastModifiedSync();
      final fileSize = await backupFile.length();

      return BackupFileInfo(
        file: backupFile,
        isValid: isValid,
        lastModified: lastModified,
        fileSize: fileSize,
      );
    } catch (e) {
      return BackupFileInfo(
        file: backupFile,
        isValid: false,
        lastModified: DateTime.now(),
        fileSize: 0,
      );
    }
  }
}

// Backup restore result
class BackupRestoreResult {
  final bool success;
  final String message;
  final BackupData? data;

  const BackupRestoreResult({
    required this.success,
    required this.message,
    this.data,
  });
}

// Backup data container
class BackupData {
  final List<Vehicle> vehicles;
  final List<Service> services;
  final List<ServiceSchedule> schedules;
  final Map<String, dynamic> metadata;

  const BackupData({
    required this.vehicles,
    required this.services,
    required this.schedules,
    required this.metadata,
  });
}

// Backup file information
class BackupFileInfo {
  final File file;
  final bool isValid;
  final DateTime lastModified;
  final int fileSize;

  const BackupFileInfo({
    required this.file,
    required this.isValid,
    required this.lastModified,
    required this.fileSize,
  });

  String get fileName => file.path.split('/').last;
  String get formattedFileSize => _formatFileSize(fileSize);

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
