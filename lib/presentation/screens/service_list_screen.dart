import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:autocare_pro/core/utils/helpers.dart';
import 'package:autocare_pro/data/models/service.dart';
import 'package:autocare_pro/presentation/providers/service_provider.dart';
import 'package:autocare_pro/presentation/widgets/service_card.dart';

// Route constants
class Routes {
  static const String dashboard = '/';
  static const String vehicleList = '/vehicles';
  static const String vehicleDetails = '/vehicle-details';
  static const String addVehicle = '/add-vehicle';
  static const String addService = '/add-service';
  static const String serviceList = '/service-list';
  static const String serviceDetails = '/service-details';
  static const String analytics = '/analytics';
  static const String settings = '/settings';
}

class ServiceListScreen extends StatefulWidget {
  final String vehicleId;

  const ServiceListScreen({super.key, required this.vehicleId});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _sortByDate = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    await context.read<ServiceProvider>().loadServicesForVehicle(widget.vehicleId);
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  void _toggleSort() {
    setState(() {
      _sortByDate = !_sortByDate;
    });
  }

  void _navigateToAddService() {
    Navigator.pushNamed(context, Routes.addService, arguments: widget.vehicleId);
  }

  void _navigateToServiceDetails(String serviceId) {
    Navigator.pushNamed(
      context,
      Routes.serviceDetails,
      arguments: serviceId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service History'),
        actions: [
          IconButton(
            icon: Icon(_sortByDate ? Icons.calendar_today : Icons.attach_money),
            onPressed: _toggleSort,
            tooltip: _sortByDate ? 'Sort by date' : 'Sort by cost',
          ),
          PopupMenuButton<String>(
            onSelected: _onFilterChanged,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All Services')),
              const PopupMenuItem(value: 'Oil Change', child: Text('Oil Changes')),
              const PopupMenuItem(value: 'Brake Service', child: Text('Brake Services')),
              const PopupMenuItem(value: 'Tire Rotation', child: Text('Tire Rotations')),
              const PopupMenuItem(value: 'Inspection', child: Text('Inspections')),
            ],
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.filter_list),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search services...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<ServiceProvider>(
        builder: (context, serviceProvider, child) {
          if (serviceProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (serviceProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading services',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    serviceProvider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadServices,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final allServices = serviceProvider.getServicesForVehicle(widget.vehicleId);
          final filteredServices = _filterAndSortServices(allServices);

          if (filteredServices.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _loadServices,
            child: _buildServiceList(filteredServices),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddService,
        tooltip: 'Add Service',
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Service> _filterAndSortServices(List<Service> services) {
    // Filter by search query
    var filtered = services.where((service) {
      if (_searchQuery.isEmpty) return true;
      return service.serviceType.displayName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          service.notes?.toLowerCase().contains(_searchQuery.toLowerCase()) == true;
    }).toList();

    // Filter by type
    if (_selectedFilter != 'All') {
      filtered = filtered.where((service) => service.serviceType.displayName == _selectedFilter).toList();
    }

    // Sort
    if (_sortByDate) {
      filtered.sort((a, b) => b.serviceDate.compareTo(a.serviceDate));
    } else {
      filtered.sort((a, b) => b.cost.compareTo(a.cost));
    }

    return filtered;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.build_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isEmpty && _selectedFilter == 'All'
                ? 'No services recorded yet'
                : 'No services found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty && _selectedFilter == 'All'
                ? 'Add your first service to get started'
                : 'Try adjusting your search or filter',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isEmpty && _selectedFilter == 'All')
            ElevatedButton.icon(
              onPressed: _navigateToAddService,
              icon: const Icon(Icons.add),
              label: const Text('Add Service'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildServiceList(List<Service> services) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return ServiceCard(
          service: service,
          onTap: () => _navigateToServiceDetails(service.id),
        );
      },
    );
  }
}
