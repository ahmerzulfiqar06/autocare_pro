import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:autocare_pro/core/utils/helpers.dart';
import 'package:autocare_pro/data/models/vehicle.dart';
import 'package:autocare_pro/data/models/service.dart';
import 'package:autocare_pro/data/models/service_schedule.dart';
import 'package:autocare_pro/data/services/search_service.dart';
import 'package:autocare_pro/presentation/providers/vehicle_provider.dart';
import 'package:autocare_pro/presentation/providers/service_provider.dart';

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

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final SearchService _searchService = SearchService();

  SearchFilter _selectedFilter = SearchFilter.all;
  SortOption _selectedSort = SortOption.relevance;
  List<SearchResult> _searchResults = [];
  List<String> _searchHistory = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSearchHistory();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadSearchHistory() {
    setState(() {
      _searchHistory = _searchService.getSearchHistory();
    });
  }

  Future<void> _loadInitialData() async {
    final vehicleProvider = context.read<VehicleProvider>();
    final serviceProvider = context.read<ServiceProvider>();

    await vehicleProvider.loadVehicles();
    await serviceProvider.loadAllServices();

    // Load default results (recent items)
    _performSearch('');
  }

  void _performSearch(String query) {
    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    final vehicleProvider = context.read<VehicleProvider>();
    final serviceProvider = context.read<ServiceProvider>();

    final vehicles = vehicleProvider.vehicles;
    final services = serviceProvider.allServices;
    final schedules = <ServiceSchedule>[]; // TODO: Add schedules when implemented

    final results = _searchService.search(
      query: query,
      vehicles: vehicles,
      services: services,
      schedules: schedules,
      filter: _selectedFilter,
      sortBy: _selectedSort,
    );

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _hasSearched = false;
      _searchResults = [];
    });
    _loadInitialData();
  }

  void _applyQuickFilter(SearchFilter filter) {
    setState(() {
      _selectedFilter = filter;
    });
    if (_searchController.text.isNotEmpty) {
      _performSearch(_searchController.text);
    }
  }

  void _applySort(SortOption sort) {
    setState(() {
      _selectedSort = sort;
    });
    if (_searchController.text.isNotEmpty || _hasSearched) {
      _performSearch(_searchController.text);
    }
  }

  void _navigateToResult(SearchResult result) {
    switch (result.type) {
      case 'vehicle':
        Navigator.pushNamed(
          context,
          Routes.vehicleDetails,
          arguments: result.id,
        );
        break;
      case 'service':
        Navigator.pushNamed(
          context,
          Routes.serviceDetails,
          arguments: result.id,
        );
        break;
      case 'schedule':
        // TODO: Navigate to schedule details when implemented
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search & Filter'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          tabs: const [
            Tab(text: 'Search'),
            Tab(text: 'Filters'),
            Tab(text: 'Quick'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSearchTab(),
          _buildFiltersTab(),
          _buildQuickTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              decoration: InputDecoration(
                hintText: 'Search vehicles, services, schedules...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      ),
                    IconButton(
                      icon: Icon(
                        _selectedFilter == SearchFilter.all ? Icons.filter_list : Icons.filter_list_alt,
                      ),
                      onPressed: () => _tabController.animateTo(1),
                    ),
                  ],
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        ),

        // Results Header
        if (_hasSearched && _searchController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${_searchResults.length} result${_searchResults.length != 1 ? 's' : ''} for "${_searchController.text}"',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const Spacer(),
                DropdownButton<SortOption>(
                  value: _selectedSort,
                  onChanged: (value) {
                    if (value != null) _applySort(value);
                  },
                  items: SortOption.values.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(option.displayName),
                    );
                  }).toList(),
                  underline: const SizedBox.shrink(),
                  icon: const Icon(Icons.sort),
                ),
              ],
            ),
          ),

        // Results List
        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator())
              : _searchResults.isEmpty && _hasSearched
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final result = _searchResults[index];
                        return _buildSearchResultCard(result);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildFiltersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Filters',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Filter Type
          Text(
            'Search In',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SearchFilter.values.map((filter) {
              return FilterChip(
                label: Text(filter.displayName),
                selected: _selectedFilter == filter,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                  if (_searchController.text.isNotEmpty) {
                    _performSearch(_searchController.text);
                  }
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Sort Options
          Text(
            'Sort By',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...SortOption.values.map((sort) {
            return RadioListTile<SortOption>(
              title: Text(sort.displayName),
              value: sort,
              groupValue: _selectedSort,
              onChanged: (value) {
                if (value != null) _applySort(value);
              },
              dense: true,
            );
          }),

          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                label: const Text('Clear All'),
                onPressed: () {
                  setState(() {
                    _selectedFilter = SearchFilter.all;
                    _selectedSort = SortOption.relevance;
                  });
                  _clearSearch();
                },
                avatar: const Icon(Icons.clear),
              ),
              ActionChip(
                label: const Text('Reset Filters'),
                onPressed: () {
                  setState(() {
                    _selectedFilter = SearchFilter.all;
                    _selectedSort = SortOption.relevance;
                  });
                },
                avatar: const Icon(Icons.refresh),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Filters',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Vehicle Status Filters
          _buildQuickFilterSection(
            'Vehicle Status',
            [
              _buildQuickFilterCard('Active Vehicles', Icons.directions_car, () {
                _applyQuickFilter(SearchFilter.vehicles);
                // TODO: Filter by active status
              }),
              _buildQuickFilterCard('Sold Vehicles', Icons.directions_car_filled, () {
                _applyQuickFilter(SearchFilter.vehicles);
                // TODO: Filter by sold status
              }),
            ],
          ),

          const SizedBox(height: 24),

          // Service Type Filters
          _buildQuickFilterSection(
            'Service Types',
            [
              _buildQuickFilterCard('Oil Changes', Icons.oil_barrel, () {
                _applyQuickFilter(SearchFilter.services);
                // TODO: Filter by oil change services
              }),
              _buildQuickFilterCard('Brake Service', Icons.car_repair, () {
                _applyQuickFilter(SearchFilter.services);
                // TODO: Filter by brake services
              }),
              _buildQuickFilterCard('Tire Service', Icons.tire_repair, () {
                _applyQuickFilter(SearchFilter.services);
                // TODO: Filter by tire services
              }),
              _buildQuickFilterCard('Inspections', Icons.search, () {
                _applyQuickFilter(SearchFilter.services);
                // TODO: Filter by inspections
              }),
            ],
          ),

          const SizedBox(height: 24),

          // Schedule Filters
          _buildQuickFilterSection(
            'Maintenance Schedules',
            [
              _buildQuickFilterCard('Due Soon', Icons.schedule, () {
                _applyQuickFilter(SearchFilter.schedules);
                // TODO: Filter by due schedules
              }),
              _buildQuickFilterCard('Overdue', Icons.warning, () {
                _applyQuickFilter(SearchFilter.schedules);
                // TODO: Filter by overdue schedules
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Column(
      children: [
        if (_searchHistory.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Searches',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _searchService.clearSearchHistory();
                    _loadSearchHistory();
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _searchHistory.length,
              itemBuilder: (context, index) {
                final query = _searchHistory[index];
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(query),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      _searchService.removeFromSearchHistory(query);
                      _loadSearchHistory();
                    },
                  ),
                  onTap: () {
                    _searchController.text = query;
                    _performSearch(query);
                    _tabController.animateTo(0);
                  },
                );
              },
            ),
          ),
        ] else
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No search history yet',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your recent searches will appear here',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildQuickFilterSection(String title, List<Widget> filters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: filters,
        ),
      ],
    );
  }

  Widget _buildQuickFilterCard(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultCard(SearchResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getResultColor(result.type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getResultIcon(result.type),
            color: _getResultColor(result.type),
          ),
        ),
        title: Text(
          result.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            if (result.description != null) ...[
              const SizedBox(height: 4),
              Text(
                result.description!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (result.date != null) ...[
              const SizedBox(height: 2),
              Text(
                Helpers.formatRelativeTime(result.date!),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        trailing: result.cost != null
            ? Text(
                Helpers.formatCurrency(result.cost!),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
        onTap: () => _navigateToResult(result),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search terms or filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _clearSearch,
            icon: const Icon(Icons.refresh),
            label: const Text('Clear Search'),
          ),
        ],
      ),
    );
  }

  Color _getResultColor(String type) {
    switch (type) {
      case 'vehicle':
        return const Color(0xFF2196F3); // Blue
      case 'service':
        return const Color(0xFF4CAF50); // Green
      case 'schedule':
        return const Color(0xFFFF9800); // Orange
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  IconData _getResultIcon(String type) {
    switch (type) {
      case 'vehicle':
        return Icons.directions_car;
      case 'service':
        return Icons.build;
      case 'schedule':
        return Icons.schedule;
      default:
        return Icons.search;
    }
  }
}
