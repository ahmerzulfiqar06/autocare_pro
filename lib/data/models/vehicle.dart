import 'package:uuid/uuid.dart';

enum VehicleStatus {
  active('Active'),
  sold('Sold'),
  serviced('Serviced');

  const VehicleStatus(this.displayName);
  final String displayName;
}

class Vehicle {
  final String id;
  final String make;
  final String model;
  final int year;
  final String? vin;
  final String? licensePlate;
  final int currentMileage;
  final DateTime? purchaseDate;
  final String? photoPath;
  final VehicleStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    String? id,
    required this.make,
    required this.model,
    required this.year,
    this.vin,
    this.licensePlate,
    required this.currentMileage,
    this.purchaseDate,
    this.photoPath,
    this.status = VehicleStatus.active,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) :
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  // Copy with method for immutability
  Vehicle copyWith({
    String? id,
    String? make,
    String? model,
    int? year,
    String? vin,
    String? licensePlate,
    int? currentMileage,
    DateTime? purchaseDate,
    String? photoPath,
    VehicleStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      vin: vin ?? this.vin,
      licensePlate: licensePlate ?? this.licensePlate,
      currentMileage: currentMileage ?? this.currentMileage,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      photoPath: photoPath ?? this.photoPath,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'year': year,
      'vin': vin,
      'license_plate': licensePlate,
      'current_mileage': currentMileage,
      'purchase_date': purchaseDate?.toIso8601String(),
      'photo_path': photoPath,
      'status': status.index,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create from Map (database retrieval)
  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as String,
      make: map['make'] as String,
      model: map['model'] as String,
      year: map['year'] as int,
      vin: map['vin'] as String?,
      licensePlate: map['license_plate'] as String?,
      currentMileage: map['current_mileage'] as int,
      purchaseDate: map['purchase_date'] != null
          ? DateTime.parse(map['purchase_date'] as String)
          : null,
      photoPath: map['photo_path'] as String?,
      status: VehicleStatus.values[map['status'] as int],
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // Display name
  String get displayName => '$year $make $model';

  // Formatted mileage
  String get formattedMileage => '${currentMileage.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  )} miles';

  @override
  String toString() {
    return 'Vehicle(id: $id, make: $make, model: $model, year: $year, mileage: $currentMileage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Vehicle && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
