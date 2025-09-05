import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:autocare_pro/data/models/vehicle.dart';
import 'package:autocare_pro/data/models/service.dart';
import 'package:autocare_pro/data/models/service_schedule.dart';

class DatabaseService {
  static const String _databaseName = 'autocare_pro.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String vehiclesTable = 'vehicles';
  static const String servicesTable = 'services';
  static const String serviceSchedulesTable = 'service_schedules';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create vehicles table
    await db.execute('''
      CREATE TABLE $vehiclesTable (
        id TEXT PRIMARY KEY,
        make TEXT NOT NULL,
        model TEXT NOT NULL,
        year INTEGER NOT NULL,
        vin TEXT,
        license_plate TEXT,
        current_mileage INTEGER NOT NULL,
        purchase_date TEXT,
        photo_path TEXT,
        status INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create services table
    await db.execute('''
      CREATE TABLE $servicesTable (
        id TEXT PRIMARY KEY,
        vehicle_id TEXT NOT NULL,
        service_type TEXT NOT NULL,
        service_date TEXT NOT NULL,
        mileage_at_service INTEGER NOT NULL,
        cost REAL NOT NULL,
        notes TEXT,
        receipt_path TEXT,
        mechanic_info TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (vehicle_id) REFERENCES $vehiclesTable (id) ON DELETE CASCADE
      )
    ''');

    // Create service schedules table
    await db.execute('''
      CREATE TABLE $serviceSchedulesTable (
        id TEXT PRIMARY KEY,
        vehicle_id TEXT NOT NULL,
        service_type TEXT NOT NULL,
        interval_miles INTEGER NOT NULL,
        interval_months INTEGER NOT NULL,
        last_service_date TEXT NOT NULL,
        last_service_mileage INTEGER NOT NULL,
        next_service_date TEXT NOT NULL,
        next_service_mileage INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (vehicle_id) REFERENCES $vehiclesTable (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_services_vehicle_id ON $servicesTable(vehicle_id)');
    await db.execute('CREATE INDEX idx_services_date ON $servicesTable(service_date)');
    await db.execute('CREATE INDEX idx_schedules_vehicle_id ON $serviceSchedulesTable(vehicle_id)');
    await db.execute('CREATE INDEX idx_schedules_next_date ON $serviceSchedulesTable(next_service_date)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    if (oldVersion < newVersion) {
      // For now, just recreate the database
      // In a production app, you'd handle migrations more carefully
      await db.execute('DROP TABLE IF EXISTS $serviceSchedulesTable');
      await db.execute('DROP TABLE IF EXISTS $servicesTable');
      await db.execute('DROP TABLE IF EXISTS $vehiclesTable');
      await _onCreate(db, newVersion);
    }
  }

  // Vehicle operations
  Future<List<Vehicle>> getAllVehicles() async {
    final db = await database;
    final maps = await db.query(vehiclesTable, orderBy: 'updated_at DESC');
    return maps.map((map) => Vehicle.fromMap(map)).toList();
  }

  Future<Vehicle?> getVehicle(String id) async {
    final db = await database;
    final maps = await db.query(
      vehiclesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Vehicle.fromMap(maps.first);
  }

  Future<String> insertVehicle(Vehicle vehicle) async {
    final db = await database;
    await db.insert(
      vehiclesTable,
      vehicle.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return vehicle.id;
  }

  Future<int> updateVehicle(Vehicle vehicle) async {
    final db = await database;
    return await db.update(
      vehiclesTable,
      vehicle.toMap(),
      where: 'id = ?',
      whereArgs: [vehicle.id],
    );
  }

  Future<int> deleteVehicle(String id) async {
    final db = await database;
    return await db.delete(
      vehiclesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Service operations
  Future<List<Service>> getServicesForVehicle(String vehicleId) async {
    final db = await database;
    final maps = await db.query(
      servicesTable,
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
      orderBy: 'service_date DESC',
    );
    return maps.map((map) => Service.fromMap(map)).toList();
  }

  Future<List<Service>> getAllServices() async {
    final db = await database;
    final maps = await db.query(
      servicesTable,
      orderBy: 'service_date DESC',
    );
    return maps.map((map) => Service.fromMap(map)).toList();
  }

  Future<String> insertService(Service service) async {
    final db = await database;
    await db.insert(
      servicesTable,
      service.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return service.id;
  }

  Future<int> updateService(Service service) async {
    final db = await database;
    return await db.update(
      servicesTable,
      service.toMap(),
      where: 'id = ?',
      whereArgs: [service.id],
    );
  }

  Future<int> deleteService(String id) async {
    final db = await database;
    return await db.delete(
      servicesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Service schedule operations
  Future<List<ServiceSchedule>> getSchedulesForVehicle(String vehicleId) async {
    final db = await database;
    final maps = await db.query(
      serviceSchedulesTable,
      where: 'vehicle_id = ? AND is_active = 1',
      whereArgs: [vehicleId],
      orderBy: 'next_service_date ASC',
    );
    return maps.map((map) => ServiceSchedule.fromMap(map)).toList();
  }

  Future<List<ServiceSchedule>> getAllActiveSchedules() async {
    final db = await database;
    final maps = await db.query(
      serviceSchedulesTable,
      where: 'is_active = 1',
      orderBy: 'next_service_date ASC',
    );
    return maps.map((map) => ServiceSchedule.fromMap(map)).toList();
  }

  Future<String> insertServiceSchedule(ServiceSchedule schedule) async {
    final db = await database;
    await db.insert(
      serviceSchedulesTable,
      schedule.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return schedule.id;
  }

  Future<int> updateServiceSchedule(ServiceSchedule schedule) async {
    final db = await database;
    return await db.update(
      serviceSchedulesTable,
      schedule.toMap(),
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }

  Future<int> deleteServiceSchedule(String id) async {
    final db = await database;
    return await db.delete(
      serviceSchedulesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Analytics queries
  Future<double> getTotalServiceCost(String vehicleId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(cost) as total FROM $servicesTable WHERE vehicle_id = ?',
      [vehicleId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalServiceCostAll() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(cost) as total FROM $servicesTable',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<Map<String, dynamic>> getServiceStats(String vehicleId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT
        COUNT(*) as service_count,
        SUM(cost) as total_cost,
        AVG(cost) as avg_cost,
        MAX(service_date) as last_service_date,
        MIN(service_date) as first_service_date
      FROM $servicesTable
      WHERE vehicle_id = ?
    ''', [vehicleId]);

    final data = result.first;
    return {
      'serviceCount': (data['service_count'] as int?) ?? 0,
      'totalCost': (data['total_cost'] as num?)?.toDouble() ?? 0.0,
      'averageCost': (data['avg_cost'] as num?)?.toDouble() ?? 0.0,
      'lastServiceDate': data['last_service_date'] != null
          ? DateTime.parse(data['last_service_date'] as String)
          : null,
      'firstServiceDate': data['first_service_date'] != null
          ? DateTime.parse(data['first_service_date'] as String)
          : null,
    };
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
