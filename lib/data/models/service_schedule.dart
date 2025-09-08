import 'package:uuid/uuid.dart';

enum ScheduleFrequency {
  mileage('Mileage-based'),
  monthly('Monthly'),
  quarterly('Quarterly'),
  semiAnnually('Semi-Annually'),
  annually('Annually'),
  custom('Custom');

  const ScheduleFrequency(this.displayName);
  final String displayName;
}

enum ScheduleServiceType {
  oilChange('Oil Change'),
  tireRotation('Tire Rotation'),
  brakeService('Brake Service'),
  transmissionService('Transmission Service'),
  engineTuneUp('Engine Tune-up'),
  airFilterReplacement('Air Filter Replacement'),
  batteryReplacement('Battery Replacement'),
  coolantFlush('Coolant Flush'),
  inspection('Inspection'),
  other('Other');

  const ScheduleServiceType(this.displayName);
  final String displayName;
}

class ServiceSchedule {
  final String id;
  final String vehicleId;
  final String serviceName;
  final String description;
  final ScheduleServiceType serviceType;
  final ScheduleFrequency frequency;

  // For mileage-based schedules
  final int? mileageInterval;
  final int? intervalMiles;

  // For time-based schedules
  final int? monthsInterval;
  final int? intervalMonths;

  final DateTime lastServiceDate;
  final int? lastServiceMileage;
  final DateTime nextServiceDate;
  final int? nextServiceMileage;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceSchedule({
    String? id,
    required this.vehicleId,
    required this.serviceName,
    required this.description,
    required this.serviceType,
    required this.frequency,
    this.mileageInterval,
    this.intervalMiles,
    this.monthsInterval,
    this.intervalMonths,
    required this.lastServiceDate,
    this.lastServiceMileage,
    DateTime? nextServiceDate,
    this.nextServiceMileage,
    this.isActive = true,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) :
    id = id ?? const Uuid().v4(),
    nextServiceDate = nextServiceDate ?? _calculateNextServiceDate(
      frequency,
      lastServiceDate,
      monthsInterval,
    ),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  // Calculate next service date based on frequency
  static DateTime _calculateNextServiceDate(
    ScheduleFrequency frequency,
    DateTime lastServiceDate,
    int? monthsInterval,
  ) {
    switch (frequency) {
      case ScheduleFrequency.monthly:
        return lastServiceDate.add(const Duration(days: 30));
      case ScheduleFrequency.quarterly:
        return lastServiceDate.add(const Duration(days: 90));
      case ScheduleFrequency.semiAnnually:
        return lastServiceDate.add(const Duration(days: 180));
      case ScheduleFrequency.annually:
        return lastServiceDate.add(const Duration(days: 365));
      case ScheduleFrequency.custom:
        if (monthsInterval != null) {
          return lastServiceDate.add(Duration(days: monthsInterval * 30));
        }
        return lastServiceDate.add(const Duration(days: 90)); // Default to quarterly
      default:
        return lastServiceDate.add(const Duration(days: 90)); // Default to quarterly
    }
  }

  // Calculate next service mileage
  static int? _calculateNextServiceMileage(
    ScheduleFrequency frequency,
    int? lastServiceMileage,
    int? mileageInterval,
  ) {
    if (frequency == ScheduleFrequency.mileage && mileageInterval != null && lastServiceMileage != null) {
      return lastServiceMileage + mileageInterval;
    }
    return null;
  }

  // Check if service is due
  bool get isDue {
    final now = DateTime.now();
    return nextServiceDate.isBefore(now) ||
           (nextServiceMileage != null && nextServiceMileage! <= 0);
  }

  // Get days until next service
  int get daysUntilDue {
    final now = DateTime.now();
    return nextServiceDate.difference(now).inDays;
  }

  // Get days until next service (alias for daysUntilDue)
  int get daysUntilNextService => daysUntilDue;

  // Get formatted next service date
  String get formattedNextServiceDate {
    return '${nextServiceDate.month}/${nextServiceDate.day}/${nextServiceDate.year}';
  }

  // Get status message
  String get statusMessage {
    if (!isActive) return 'Inactive';

    if (isDue) {
      return 'Overdue by ${-daysUntilDue} days';
    } else if (daysUntilDue <= 7) {
      return 'Due in $daysUntilDue days';
    } else if (daysUntilDue <= 30) {
      return 'Due in ${daysUntilDue} days';
    } else {
      return 'Next service: ${formattedNextServiceDate}';
    }
  }

  // Get status color
  String get statusColor {
    if (!isActive) return 'grey';
    if (isDue) return 'red';
    if (daysUntilDue <= 7) return 'orange';
    if (daysUntilDue <= 30) return 'yellow';
    return 'green';
  }

  // Copy with method for immutability
  ServiceSchedule copyWith({
    String? id,
    String? vehicleId,
    String? serviceName,
    String? description,
    ScheduleServiceType? serviceType,
    ScheduleFrequency? frequency,
    int? mileageInterval,
    int? intervalMiles,
    int? monthsInterval,
    int? intervalMonths,
    DateTime? lastServiceDate,
    int? lastServiceMileage,
    DateTime? nextServiceDate,
    int? nextServiceMileage,
    bool? isActive,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceSchedule(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      serviceName: serviceName ?? this.serviceName,
      description: description ?? this.description,
      serviceType: serviceType ?? this.serviceType,
      frequency: frequency ?? this.frequency,
      mileageInterval: mileageInterval ?? this.mileageInterval,
      intervalMiles: intervalMiles ?? this.intervalMiles,
      monthsInterval: monthsInterval ?? this.monthsInterval,
      intervalMonths: intervalMonths ?? this.intervalMonths,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      lastServiceMileage: lastServiceMileage ?? this.lastServiceMileage,
      nextServiceDate: nextServiceDate ?? this.nextServiceDate,
      nextServiceMileage: nextServiceMileage ?? this.nextServiceMileage,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'serviceName': serviceName,
      'description': description,
      'serviceType': serviceType.name,
      'frequency': frequency.name,
      'mileageInterval': mileageInterval,
      'intervalMiles': intervalMiles,
      'monthsInterval': monthsInterval,
      'intervalMonths': intervalMonths,
      'lastServiceDate': lastServiceDate.toIso8601String(),
      'lastServiceMileage': lastServiceMileage,
      'nextServiceDate': nextServiceDate.toIso8601String(),
      'nextServiceMileage': nextServiceMileage,
      'isActive': isActive ? 1 : 0,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from Map (database retrieval)
  factory ServiceSchedule.fromMap(Map<String, dynamic> map) {
    return ServiceSchedule(
      id: map['id'] as String,
      vehicleId: map['vehicleId'] as String,
      serviceName: map['serviceName'] as String,
      description: map['description'] as String,
      serviceType: ScheduleServiceType.values.firstWhere(
        (s) => s.name == map['serviceType'],
        orElse: () => ScheduleServiceType.other,
      ),
      frequency: ScheduleFrequency.values.firstWhere(
        (f) => f.name == map['frequency'],
        orElse: () => ScheduleFrequency.quarterly,
      ),
      mileageInterval: map['mileageInterval'] as int?,
      intervalMiles: map['intervalMiles'] as int?,
      monthsInterval: map['monthsInterval'] as int?,
      intervalMonths: map['intervalMonths'] as int?,
      lastServiceDate: DateTime.parse(map['lastServiceDate'] as String),
      lastServiceMileage: map['lastServiceMileage'] as int?,
      nextServiceDate: DateTime.parse(map['nextServiceDate'] as String),
      nextServiceMileage: map['nextServiceMileage'] as int?,
      isActive: (map['isActive'] as int?) == 1,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'ServiceSchedule(id: $id, serviceName: $serviceName, nextServiceDate: $nextServiceDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceSchedule && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}