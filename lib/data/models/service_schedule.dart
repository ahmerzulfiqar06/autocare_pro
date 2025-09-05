import 'package:uuid/uuid.dart';

class ServiceSchedule {
  final String id;
  final String vehicleId;
  final String serviceType;
  final int intervalMiles;
  final int intervalMonths;
  final DateTime lastServiceDate;
  final int lastServiceMileage;
  final DateTime nextServiceDate;
  final int nextServiceMileage;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceSchedule({
    String? id,
    required this.vehicleId,
    required this.serviceType,
    required this.intervalMiles,
    required this.intervalMonths,
    required this.lastServiceDate,
    required this.lastServiceMileage,
    DateTime? nextServiceDate,
    int? nextServiceMileage,
    this.isActive = true,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) :
    id = id ?? const Uuid().v4(),
    nextServiceDate = nextServiceDate ?? _calculateNextServiceDate(
      lastServiceDate,
      intervalMonths,
    ),
    nextServiceMileage = nextServiceMileage ?? lastServiceMileage + intervalMiles,
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  // Calculate next service date based on interval
  static DateTime _calculateNextServiceDate(DateTime lastServiceDate, int intervalMonths) {
    return DateTime(
      lastServiceDate.year,
      lastServiceDate.month + intervalMonths,
      lastServiceDate.day,
    );
  }

  // Copy with method for immutability
  ServiceSchedule copyWith({
    String? id,
    String? vehicleId,
    String? serviceType,
    int? intervalMiles,
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
      serviceType: serviceType ?? this.serviceType,
      intervalMiles: intervalMiles ?? this.intervalMiles,
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
      'vehicle_id': vehicleId,
      'service_type': serviceType,
      'interval_miles': intervalMiles,
      'interval_months': intervalMonths,
      'last_service_date': lastServiceDate.toIso8601String(),
      'last_service_mileage': lastServiceMileage,
      'next_service_date': nextServiceDate.toIso8601String(),
      'next_service_mileage': nextServiceMileage,
      'is_active': isActive ? 1 : 0,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create from Map (database retrieval)
  factory ServiceSchedule.fromMap(Map<String, dynamic> map) {
    return ServiceSchedule(
      id: map['id'] as String,
      vehicleId: map['vehicle_id'] as String,
      serviceType: map['service_type'] as String,
      intervalMiles: map['interval_miles'] as int,
      intervalMonths: map['interval_months'] as int,
      lastServiceDate: DateTime.parse(map['last_service_date'] as String),
      lastServiceMileage: map['last_service_mileage'] as int,
      nextServiceDate: DateTime.parse(map['next_service_date'] as String),
      nextServiceMileage: map['next_service_mileage'] as int,
      isActive: (map['is_active'] as int) == 1,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // Check if service is due based on current mileage and date
  bool isServiceDue(int currentMileage, DateTime currentDate) {
    final mileageDue = currentMileage >= nextServiceMileage;
    final dateDue = currentDate.isAfter(nextServiceDate) ||
                   currentDate.isAtSameMomentAs(nextServiceDate);

    return mileageDue || dateDue;
  }

  // Get days until next service
  int get daysUntilNextService {
    final now = DateTime.now();
    return nextServiceDate.difference(now).inDays;
  }

  // Get miles until next service
  int get milesUntilNextService {
    return nextServiceMileage - lastServiceMileage;
  }

  // Formatted next service date
  String get formattedNextServiceDate {
    final days = daysUntilNextService;
    if (days < 0) {
      return 'Overdue by ${days.abs()} days';
    } else if (days == 0) {
      return 'Due today';
    } else if (days == 1) {
      return 'Due tomorrow';
    } else if (days < 7) {
      return 'Due in $days days';
    } else if (days < 30) {
      final weeks = (days / 7).floor();
      return 'Due in $weeks week${weeks == 1 ? '' : 's'}';
    } else {
      final months = (days / 30).floor();
      return 'Due in $months month${months == 1 ? '' : 's'}';
    }
  }

  // Formatted intervals
  String get formattedIntervals {
    final miles = intervalMiles.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    if (intervalMiles > 0 && intervalMonths > 0) {
      return 'Every $miles miles or $intervalMonths months';
    } else if (intervalMiles > 0) {
      return 'Every $miles miles';
    } else {
      return 'Every $intervalMonths months';
    }
  }

  @override
  String toString() {
    return 'ServiceSchedule(id: $id, type: $serviceType, next: $nextServiceDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceSchedule && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
