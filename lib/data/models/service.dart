import 'package:uuid/uuid.dart';

enum ServiceType {
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

  const ServiceType(this.displayName);
  final String displayName;

  static ServiceType fromString(String value) {
    return ServiceType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => ServiceType.other,
    );
  }
}

class Service {
  final String id;
  final String vehicleId;
  final ServiceType serviceType;
  final DateTime serviceDate;
  final int mileageAtService;
  final double cost;
  final String? notes;
  final String? receiptPath;
  final String? mechanicInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  Service({
    String? id,
    required this.vehicleId,
    required this.serviceType,
    required this.serviceDate,
    required this.mileageAtService,
    required this.cost,
    this.notes,
    this.receiptPath,
    this.mechanicInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) :
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  // Copy with method for immutability
  Service copyWith({
    String? id,
    String? vehicleId,
    ServiceType? serviceType,
    DateTime? serviceDate,
    int? mileageAtService,
    double? cost,
    String? notes,
    String? receiptPath,
    String? mechanicInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Service(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      serviceType: serviceType ?? this.serviceType,
      serviceDate: serviceDate ?? this.serviceDate,
      mileageAtService: mileageAtService ?? this.mileageAtService,
      cost: cost ?? this.cost,
      notes: notes ?? this.notes,
      receiptPath: receiptPath ?? this.receiptPath,
      mechanicInfo: mechanicInfo ?? this.mechanicInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'service_type': serviceType.name,
      'service_date': serviceDate.toIso8601String(),
      'mileage_at_service': mileageAtService,
      'cost': cost,
      'notes': notes,
      'receipt_path': receiptPath,
      'mechanic_info': mechanicInfo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create from Map (database retrieval)
  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'] as String,
      vehicleId: map['vehicle_id'] as String,
      serviceType: ServiceType.fromString(map['service_type'] as String),
      serviceDate: DateTime.parse(map['service_date'] as String),
      mileageAtService: map['mileage_at_service'] as int,
      cost: map['cost'] as double,
      notes: map['notes'] as String?,
      receiptPath: map['receipt_path'] as String?,
      mechanicInfo: map['mechanic_info'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // Formatted cost
  String get formattedCost => '\$${cost.toStringAsFixed(2)}';

  // Formatted mileage
  String get formattedMileage => '${mileageAtService.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  )} miles';

  // Formatted date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(serviceDate).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    } else if (difference < 365) {
      final months = (difference / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else {
      final years = (difference / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    }
  }

  @override
  String toString() {
    return 'Service(id: $id, type: ${serviceType.displayName}, date: $serviceDate, cost: $cost)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Service && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
