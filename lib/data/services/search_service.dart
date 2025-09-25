import 'package:autocare_pro/data/models/vehicle.dart';
import 'package:autocare_pro/data/models/service.dart';
import 'package:autocare_pro/data/models/service_schedule.dart';

enum SearchFilter {
  all('All'),
  vehicles('Vehicles'),
  services('Services'),
  schedules('Schedules'),
  overdue('Overdue Items'),
  upcoming('Upcoming Services'),
  highPriority('High Priority');

  const SearchFilter(this.displayName);
  final String displayName;
}

enum SortOption {
  relevance('Relevance'),
  dateNewest('Newest First'),
  dateOldest('Oldest First'),
  nameAZ('Name A-Z'),
  nameZA('Name Z-A'),
  costHigh('Cost High-Low'),
  costLow('Cost Low-High'),
  mileageHigh('Mileage High-Low'),
  mileageLow('Mileage Low-High'),
  priorityHigh('Priority High-Low'),
  dueSoon('Due Soon');

  const SortOption(this.displayName);
  final String displayName;
}

class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final String type; // 'vehicle', 'service', 'schedule'
  final String? description;
  final DateTime? date;
  final double? cost;
  final int? mileage;
  final String? imageUrl;
  final Map<String, dynamic> metadata;

  SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    this.description,
    this.date,
    this.cost,
    this.mileage,
    this.imageUrl,
    this.metadata = const {},
  });

  @override
  String toString() => '$type: $title - $subtitle';
}

class SearchService {
  static final SearchService _instance = SearchService._internal();
  factory SearchService() => _instance;
  SearchService._internal();

  // Search history
  final List<String> _searchHistory = [];
  static const int _maxHistorySize = 10;

  // Perform global search
  List<SearchResult> search({
    required String query,
    required List<Vehicle> vehicles,
    required List<Service> services,
    required List<ServiceSchedule> schedules,
    SearchFilter filter = SearchFilter.all,
    SortOption sortBy = SortOption.relevance,
  }) {
    return performAdvancedSearch(
      query: query,
      vehicles: vehicles,
      services: services,
      schedules: schedules,
      filter: filter,
      sortBy: sortBy,
    );
  }

  // Advanced search with comprehensive filtering
  List<SearchResult> performAdvancedSearch({
    String? query,
    required List<Vehicle> vehicles,
    required List<Service> services,
    required List<ServiceSchedule> schedules,
    SearchFilter filter = SearchFilter.all,
    SortOption sortBy = SortOption.relevance,
    DateTime? dateFrom,
    DateTime? dateTo,
    double? costMin,
    double? costMax,
    int? mileageMin,
    int? mileageMax,
    List<String>? serviceTypes,
  }) {
    if (query.trim().isEmpty) {
      return _getDefaultResults(vehicles, services, schedules, filter, sortBy);
    }

    final results = <SearchResult>[];

    // Add to search history
    _addToSearchHistory(query);

    final searchTerm = query.toLowerCase().trim();

    // Search vehicles
    if (filter == SearchFilter.all || filter == SearchFilter.vehicles) {
      for (final vehicle in vehicles) {
        if (_matchesVehicle(vehicle, searchTerm)) {
          results.add(SearchResult(
            id: vehicle.id,
            title: '${vehicle.year} ${vehicle.make} ${vehicle.model}',
            subtitle: 'Vehicle',
            type: 'vehicle',
            description: vehicle.licensePlate ?? 'No license plate',
            date: vehicle.createdAt,
            imageUrl: vehicle.photoPath,
            metadata: {
              'make': vehicle.make,
              'model': vehicle.model,
              'year': vehicle.year,
              'mileage': vehicle.currentMileage,
              'vin': vehicle.vin,
              'status': vehicle.status.displayName,
            },
          ));
        }
      }
    }

    // Search services
    if (filter == SearchFilter.all || filter == SearchFilter.services) {
      for (final service in services) {
        if (_matchesService(service, searchTerm, vehicles)) {
          final vehicle = vehicles.firstWhere(
            (v) => v.id == service.vehicleId,
            orElse: () => Vehicle(
              make: 'Unknown',
              model: 'Vehicle',
              year: 2020,
              currentMileage: 0,
            ),
          );

          results.add(SearchResult(
            id: service.id,
            title: service.serviceType.displayName,
            subtitle: '${vehicle.year} ${vehicle.make} ${vehicle.model}',
            type: 'service',
            description: service.notes ?? 'No description',
            date: service.serviceDate,
            cost: service.cost,
            mileage: service.mileageAtService,
            metadata: {
              'serviceType': service.serviceType.name,
              'mechanic': service.mechanicInfo,
              'receipt': service.receiptPath,
              'vehicleId': service.vehicleId,
            },
          ));
        }
      }
    }

    // Search schedules
    if (filter == SearchFilter.all || filter == SearchFilter.schedules) {
      for (final schedule in schedules) {
        if (_matchesSchedule(schedule, searchTerm, vehicles)) {
          final vehicle = vehicles.firstWhere(
            (v) => v.id == schedule.vehicleId,
            orElse: () => Vehicle(
              make: 'Unknown',
              model: 'Vehicle',
              year: 2020,
              currentMileage: 0,
            ),
          );

          results.add(SearchResult(
            id: schedule.id,
            title: schedule.serviceName,
            subtitle: '${vehicle.year} ${vehicle.make} ${vehicle.model}',
            type: 'schedule',
            description: schedule.description,
            date: schedule.nextServiceDate,
            metadata: {
              'frequency': schedule.frequency.displayName,
              'isActive': schedule.isActive,
              'isDue': schedule.isDue,
              'daysUntilDue': schedule.daysUntilDue,
              'vehicleId': schedule.vehicleId,
            },
          ));
        }
      }
    }

    // Sort results
    results.sort((a, b) => _compareResults(a, b, sortBy));

    return results;
  }

  bool _matchesVehicle(Vehicle vehicle, String searchTerm) {
    return vehicle.make.toLowerCase().contains(searchTerm) ||
           vehicle.model.toLowerCase().contains(searchTerm) ||
           vehicle.year.toString().contains(searchTerm) ||
           (vehicle.licensePlate?.toLowerCase().contains(searchTerm) ?? false) ||
           (vehicle.vin?.toLowerCase().contains(searchTerm) ?? false) ||
           (vehicle.notes?.toLowerCase().contains(searchTerm) ?? false);
  }

  bool _matchesService(Service service, String searchTerm, List<Vehicle> vehicles) {
    // Search in service details
    if (service.serviceType.displayName.toLowerCase().contains(searchTerm) ||
        (service.notes?.toLowerCase().contains(searchTerm) ?? false) ||
        (service.mechanicInfo?.toLowerCase().contains(searchTerm) ?? false)) {
      return true;
    }

    // Search in associated vehicle
    final vehicle = vehicles.firstWhere(
      (v) => v.id == service.vehicleId,
      orElse: () => Vehicle(make: '', model: '', year: 0, currentMileage: 0),
    );

    return vehicle.make.toLowerCase().contains(searchTerm) ||
           vehicle.model.toLowerCase().contains(searchTerm) ||
           vehicle.year.toString().contains(searchTerm);
  }

  bool _matchesSchedule(ServiceSchedule schedule, String searchTerm, List<Vehicle> vehicles) {
    // Search in schedule details
    if (schedule.serviceName.toLowerCase().contains(searchTerm) ||
        schedule.description.toLowerCase().contains(searchTerm) ||
        (schedule.notes?.toLowerCase().contains(searchTerm) ?? false)) {
      return true;
    }

    // Search in associated vehicle
    final vehicle = vehicles.firstWhere(
      (v) => v.id == schedule.vehicleId,
      orElse: () => Vehicle(make: '', model: '', year: 0, currentMileage: 0),
    );

    return vehicle.make.toLowerCase().contains(searchTerm) ||
           vehicle.model.toLowerCase().contains(searchTerm) ||
           vehicle.year.toString().contains(searchTerm);
  }

  int _compareResults(SearchResult a, SearchResult b, SortOption sortBy) {
    switch (sortBy) {
      case SortOption.relevance:
        // For now, sort by type priority: vehicles > services > schedules
        final typePriority = {'vehicle': 3, 'service': 2, 'schedule': 1};
        final aPriority = typePriority[a.type] ?? 0;
        final bPriority = typePriority[b.type] ?? 0;
        return bPriority.compareTo(aPriority);

      case SortOption.dateNewest:
        final aDate = a.date ?? DateTime(2000);
        final bDate = b.date ?? DateTime(2000);
        return bDate.compareTo(aDate);

      case SortOption.dateOldest:
        final aDate = a.date ?? DateTime(2100);
        final bDate = b.date ?? DateTime(2100);
        return aDate.compareTo(bDate);

      case SortOption.nameAZ:
        return a.title.compareTo(b.title);

      case SortOption.nameZA:
        return b.title.compareTo(a.title);

      case SortOption.costHigh:
        final aCost = a.cost ?? 0.0;
        final bCost = b.cost ?? 0.0;
        return bCost.compareTo(aCost);

      case SortOption.costLow:
        final aCost = a.cost ?? double.maxFinite;
        final bCost = b.cost ?? double.maxFinite;
        return aCost.compareTo(bCost);
    }
  }

  List<SearchResult> _getDefaultResults(
    List<Vehicle> vehicles,
    List<Service> services,
    List<ServiceSchedule> schedules,
    SearchFilter filter,
    SortOption sortBy,
  ) {
    // Return recent items when no search query
    final results = <SearchResult>[];

    // Add recent vehicles
    if (filter == SearchFilter.all || filter == SearchFilter.vehicles) {
      final recentVehicles = vehicles.take(5);
      for (final vehicle in recentVehicles) {
        results.add(SearchResult(
          id: vehicle.id,
          title: '${vehicle.year} ${vehicle.make} ${vehicle.model}',
          subtitle: 'Recent Vehicle',
          type: 'vehicle',
          description: vehicle.licensePlate ?? 'No license plate',
          date: vehicle.createdAt,
          imageUrl: vehicle.photoPath,
        ));
      }
    }

    // Add recent services
    if (filter == SearchFilter.all || filter == SearchFilter.services) {
      final recentServices = services.take(5);
      for (final service in recentServices) {
        final vehicle = vehicles.firstWhere(
          (v) => v.id == service.vehicleId,
          orElse: () => Vehicle(make: 'Unknown', model: 'Vehicle', year: 2020, currentMileage: 0),
        );

        results.add(SearchResult(
          id: service.id,
          title: service.serviceType.displayName,
          subtitle: '${vehicle.year} ${vehicle.make} ${vehicle.model}',
          type: 'service',
          description: service.notes ?? 'No description',
          date: service.serviceDate,
          cost: service.cost,
        ));
      }
    }

    return results.take(10).toList(); // Limit to 10 results
  }

  // Search history management
  void _addToSearchHistory(String query) {
    if (query.trim().isEmpty) return;

    _searchHistory.remove(query); // Remove if already exists
    _searchHistory.insert(0, query); // Add to beginning

    // Keep only the most recent searches
    if (_searchHistory.length > _maxHistorySize) {
      _searchHistory.removeRange(_maxHistorySize, _searchHistory.length);
    }
  }

  List<String> getSearchHistory() => List.unmodifiable(_searchHistory);

  void clearSearchHistory() => _searchHistory.clear();

  void removeFromSearchHistory(String query) => _searchHistory.remove(query);

  // Quick filters
  List<SearchResult> getVehiclesByStatus(List<Vehicle> vehicles, String status) {
    final filteredVehicles = vehicles.where((vehicle) =>
      vehicle.status.displayName.toLowerCase() == status.toLowerCase()
    );

    return filteredVehicles.map((vehicle) => SearchResult(
      id: vehicle.id,
      title: '${vehicle.year} ${vehicle.make} ${vehicle.model}',
      subtitle: 'Status: ${vehicle.status.displayName}',
      type: 'vehicle',
      description: vehicle.licensePlate ?? 'No license plate',
      date: vehicle.createdAt,
      imageUrl: vehicle.photoPath,
    )).toList();
  }

  List<SearchResult> getServicesByType(List<Service> services, List<Vehicle> vehicles, String serviceType) {
    final filteredServices = services.where((service) =>
      service.serviceType.displayName.toLowerCase().contains(serviceType.toLowerCase())
    );

    return filteredServices.map((service) {
      final vehicle = vehicles.firstWhere(
        (v) => v.id == service.vehicleId,
        orElse: () => Vehicle(make: 'Unknown', model: 'Vehicle', year: 2020, currentMileage: 0),
      );

      return SearchResult(
        id: service.id,
        title: service.serviceType.displayName,
        subtitle: '${vehicle.year} ${vehicle.make} ${vehicle.model}',
        type: 'service',
        description: service.notes ?? 'No description',
        date: service.serviceDate,
        cost: service.cost,
      );
    }).toList();
  }

  List<SearchResult> getDueSchedules(List<ServiceSchedule> schedules, List<Vehicle> vehicles) {
    final dueSchedules = schedules.where((schedule) => schedule.isDue);

    return dueSchedules.map((schedule) {
      final vehicle = vehicles.firstWhere(
        (v) => v.id == schedule.vehicleId,
        orElse: () => Vehicle(make: 'Unknown', model: 'Vehicle', year: 2020, currentMileage: 0),
      );

      return SearchResult(
        id: schedule.id,
        title: schedule.serviceName,
        subtitle: '${vehicle.year} ${vehicle.make} ${vehicle.model}',
        type: 'schedule',
        description: schedule.description,
        date: schedule.nextServiceDate,
        metadata: {
          'isDue': true,
          'daysUntilDue': schedule.daysUntilDue,
        },
      );
    }).toList();
  }

  // Advanced filtering
  List<SearchResult> filterByDateRange({
    required List<Vehicle> vehicles,
    required List<Service> services,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final results = <SearchResult>[];

    // Filter services by date range
    final filteredServices = services.where((service) {
      return service.serviceDate.isAfter(startDate) &&
             service.serviceDate.isBefore(endDate);
    });

    for (final service in filteredServices) {
      final vehicle = vehicles.firstWhere(
        (v) => v.id == service.vehicleId,
        orElse: () => Vehicle(make: 'Unknown', model: 'Vehicle', year: 2020, currentMileage: 0),
      );

      results.add(SearchResult(
        id: service.id,
        title: service.serviceType.displayName,
        subtitle: '${vehicle.year} ${vehicle.make} ${vehicle.model}',
        type: 'service',
        description: 'Date: ${service.serviceDate.toLocal()}',
        date: service.serviceDate,
        cost: service.cost,
      ));
    }

    return results;
  }

  List<SearchResult> filterByCostRange({
    required List<Service> services,
    required List<Vehicle> vehicles,
    required double minCost,
    required double maxCost,
  }) {
    final filteredServices = services.where((service) {
      return service.cost >= minCost && service.cost <= maxCost;
    });

    return filteredServices.map((service) {
      final vehicle = vehicles.firstWhere(
        (v) => v.id == service.vehicleId,
        orElse: () => Vehicle(make: 'Unknown', model: 'Vehicle', year: 2020, currentMileage: 0),
      );

      return SearchResult(
        id: service.id,
        title: service.serviceType.displayName,
        subtitle: '${vehicle.year} ${vehicle.make} ${vehicle.model}',
        type: 'service',
        description: '\$${service.cost.toStringAsFixed(2)}',
        date: service.serviceDate,
        cost: service.cost,
      );
    }).toList();
  }

  // Get overdue items (services and schedules)
  List<SearchResult> getOverdueItems({
    required List<Vehicle> vehicles,
    required List<Service> services,
    required List<ServiceSchedule> schedules,
  }) {
    final results = <SearchResult>[];
    final now = DateTime.now();

    // Overdue services
    for (final service in services) {
      if (service.serviceDate.isBefore(now.subtract(const Duration(days: 30)))) {
        final vehicle = vehicles.firstWhere(
          (v) => v.id == service.vehicleId,
          orElse: () => Vehicle(make: 'Unknown', model: 'Vehicle', year: 2020, currentMileage: 0),
        );

        results.add(SearchResult(
          id: service.id,
          title: service.serviceType.displayName,
          subtitle: '${vehicle.year} ${vehicle.make} ${vehicle.model}',
          type: 'service',
          description: 'Overdue by ${now.difference(service.serviceDate).inDays} days',
          date: service.serviceDate,
          cost: service.cost,
          metadata: {'isOverdue': true, 'daysOverdue': now.difference(service.serviceDate).inDays},
        ));
      }
    }

    // Overdue schedules
    for (final schedule in schedules) {
      if (schedule.isDue) {
        final vehicle = vehicles.firstWhere(
          (v) => v.id == schedule.vehicleId,
          orElse: () => Vehicle(make: 'Unknown', model: 'Vehicle', year: 2020, currentMileage: 0),
        );

        results.add(SearchResult(
          id: schedule.id,
          title: schedule.serviceName,
          subtitle: '${vehicle.year} ${vehicle.make} ${vehicle.model}',
          type: 'schedule',
          description: 'Overdue by ${-schedule.daysUntilDue} days',
          date: schedule.nextServiceDate,
          metadata: {'isOverdue': true, 'daysOverdue': -schedule.daysUntilDue},
        ));
      }
    }

    return _sortResults(results, SortOption.dueSoon);
  }

  // Get upcoming services (next 7 days)
  List<SearchResult> getUpcomingServices({
    required List<Vehicle> vehicles,
    required List<ServiceSchedule> schedules,
    int days = 7,
  }) {
    final results = <SearchResult>[];
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));

    for (final schedule in schedules) {
      if (schedule.nextServiceDate.isAfter(now) &&
          schedule.nextServiceDate.isBefore(futureDate)) {
        final vehicle = vehicles.firstWhere(
          (v) => v.id == schedule.vehicleId,
          orElse: () => Vehicle(make: 'Unknown', model: 'Vehicle', year: 2020, currentMileage: 0),
        );

        results.add(SearchResult(
          id: schedule.id,
          title: schedule.serviceName,
          subtitle: '${vehicle.year} ${vehicle.make} ${vehicle.model}',
          type: 'schedule',
          description: 'Due in ${schedule.daysUntilDue} days',
          date: schedule.nextServiceDate,
          metadata: {'daysUntilDue': schedule.daysUntilDue},
        ));
      }
    }

    return _sortResults(results, SortOption.dueSoon);
  }

  // Get high priority items
  List<SearchResult> getHighPriorityItems({
    required List<Vehicle> vehicles,
    required List<Service> services,
    required List<ServiceSchedule> schedules,
  }) {
    final results = <SearchResult>[];

    // High priority services (safety related)
    for (final service in services) {
      if (_isHighPriorityService(service.serviceType)) {
        final vehicle = vehicles.firstWhere(
          (v) => v.id == service.vehicleId,
          orElse: () => Vehicle(make: 'Unknown', model: 'Vehicle', year: 2020, currentMileage: 0),
        );

        results.add(SearchResult(
          id: service.id,
          title: service.serviceType.displayName,
          subtitle: '${vehicle.year} ${vehicle.make} ${vehicle.model}',
          type: 'service',
          description: 'High Priority Service',
          date: service.serviceDate,
          cost: service.cost,
          metadata: {'isHighPriority': true},
        ));
      }
    }

    // High priority schedules
    for (final schedule in schedules) {
      if (_isHighPrioritySchedule(schedule.serviceType)) {
        final vehicle = vehicles.firstWhere(
          (v) => v.id == schedule.vehicleId,
          orElse: () => Vehicle(make: 'Unknown', model: 'Vehicle', year: 2020, currentMileage: 0),
        );

        results.add(SearchResult(
          id: schedule.id,
          title: schedule.serviceName,
          subtitle: '${vehicle.year} ${vehicle.make} ${vehicle.model}',
          type: 'schedule',
          description: 'High Priority Service',
          date: schedule.nextServiceDate,
          metadata: {'isHighPriority': true},
        ));
      }
    }

    return _sortResults(results, SortOption.priorityHigh);
  }

  bool _isHighPriorityService(ServiceType serviceType) {
    return serviceType == ServiceType.brakeService ||
           serviceType == ServiceType.tireRotation ||
           serviceType == ServiceType.inspection;
  }

  bool _isHighPrioritySchedule(ScheduleServiceType serviceType) {
    return serviceType == ScheduleServiceType.brakeService ||
           serviceType == ScheduleServiceType.tireRotation ||
           serviceType == ScheduleServiceType.inspection;
  }

  List<SearchResult> _sortResults(List<SearchResult> results, SortOption sort) {
    results.sort((a, b) {
      switch (sort) {
        case SortOption.relevance:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case SortOption.dateNewest:
          if (a.date != null && b.date != null) {
            return b.date!.compareTo(a.date!);
          }
          return 0;
        case SortOption.dateOldest:
          if (a.date != null && b.date != null) {
            return a.date!.compareTo(b.date!);
          }
          return 0;
        case SortOption.nameAZ:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case SortOption.nameZA:
          return b.title.toLowerCase().compareTo(a.title.toLowerCase());
        case SortOption.costHigh:
          if (a.cost != null && b.cost != null) {
            return b.cost!.compareTo(a.cost!);
          }
          return 0;
        case SortOption.costLow:
          if (a.cost != null && b.cost != null) {
            return a.cost!.compareTo(b.cost!);
          }
          return 0;
        case SortOption.mileageHigh:
          if (a.mileage != null && b.mileage != null) {
            return b.mileage!.compareTo(a.mileage!);
          }
          return 0;
        case SortOption.mileageLow:
          if (a.mileage != null && b.mileage != null) {
            return a.mileage!.compareTo(b.mileage!);
          }
          return 0;
        case SortOption.priorityHigh:
          return _getPriorityScore(b).compareTo(_getPriorityScore(a));
        case SortOption.dueSoon:
          return _getDueSoonScore(a).compareTo(_getDueSoonScore(b));
      }
    });

    return results;
  }

  int _getPriorityScore(SearchResult result) {
    final metadata = result.metadata;
    if (metadata['isHighPriority'] == true) return 3;
    if (metadata['isOverdue'] == true) return 2;
    return 1;
  }

  int _getDueSoonScore(SearchResult result) {
    final metadata = result.metadata;
    if (metadata['isOverdue'] == true) return 3;
    final daysUntil = metadata['daysUntilDue'] as int?;
    if (daysUntil != null && daysUntil <= 3) return 2;
    return 1;
  }
}
