import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:autocare_pro/core/utils/helpers.dart';
import 'package:autocare_pro/data/models/service.dart';
import 'package:autocare_pro/presentation/providers/service_provider.dart';
import 'package:autocare_pro/presentation/providers/vehicle_provider.dart';
import 'package:autocare_pro/presentation/widgets/analytics_chart.dart';
import 'package:autocare_pro/presentation/widgets/export_dialog.dart';
import 'package:autocare_pro/core/widgets/custom_icon.dart';
import 'package:autocare_pro/data/services/connectivity_service.dart';

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

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with TickerProviderStateMixin {
  String _selectedPeriod = 'All Time';
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Load all data
    final vehicleProvider = context.read<VehicleProvider>();
    final serviceProvider = context.read<ServiceProvider>();

    await vehicleProvider.loadVehicles();
    await serviceProvider.loadAllServices();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Insights'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'export') {
                _showExportDialog(context);
                return;
              }
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All Time', child: Text('All Time')),
              const PopupMenuItem(value: 'This Year', child: Text('This Year')),
              const PopupMenuItem(value: 'This Month', child: Text('This Month')),
              const PopupMenuItem(value: 'Last 3 Months', child: Text('Last 3 Months')),
              const PopupMenuItem(value: 'export', child: Row(
                children: [
                  const Icon(Icons.download, size: 18),
                  const SizedBox(width: 8),
                  const Text('Export Data'),
                ],
              )),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    _selectedPeriod,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Trends'),
            Tab(text: 'Breakdown'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analyzing your data...'),
                ],
              ),
            )
          : OfflineAwareWrapper(
              offlineWidget: _buildOfflineAnalytics(),
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildTrendsTab(),
                    _buildBreakdownTab(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer2<VehicleProvider, ServiceProvider>(
      builder: (context, vehicleProvider, serviceProvider, child) {
        final totalVehicles = vehicleProvider.totalVehiclesCount;
        final activeVehicles = vehicleProvider.activeVehiclesCount;
        final totalServices = serviceProvider.totalServicesCount;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Maintenance Insights',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track your vehicle maintenance costs and patterns',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Key Metrics Cards
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Total Vehicles',
                      value: totalVehicles.toString(),
                      icon: const CustomIcon(
                        iconPath: AppIcons.car,
                        size: 20,
                        color: Color(0xFF2196F3),
                      ),
                      color: const Color(0xFF2196F3),
                      trend: '+12%',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Active Vehicles',
                      value: activeVehicles.toString(),
                      icon: const CustomIcon(
                        iconPath: AppIcons.car,
                        size: 20,
                        color: Color(0xFF4CAF50),
                      ),
                      color: const Color(0xFF4CAF50),
                      trend: '+8%',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Services Logged',
                      value: totalServices.toString(),
                      icon: const CustomIcon(
                        iconPath: AppIcons.wrench,
                        size: 20,
                        color: Color(0xFFFF9800),
                      ),
                      color: const Color(0xFFFF9800),
                      trend: '+15%',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FutureBuilder<double>(
                      future: serviceProvider.getTotalServiceCostAll(),
                      builder: (context, snapshot) {
                        final totalCost = snapshot.data ?? 0.0;
                        return _buildMetricCard(
                          title: 'Total Spent',
                          value: Helpers.formatCurrency(totalCost),
                          icon: const CustomIcon(
                            iconPath: AppIcons.money,
                            size: 20,
                            color: Color(0xFFE91E63),
                          ),
                          color: const Color(0xFFE91E63),
                          trend: '+5%',
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Insights
              Text(
                'Quick Insights',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildInsightCard(
                icon: const CustomIcon(
                  iconPath: AppIcons.chart,
                  size: 20,
                  color: Colors.green,
                ),
                title: 'Cost Efficiency',
                description: 'Your average service cost is 8% lower than last month',
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              _buildInsightCard(
                icon: const CustomIcon(
                  iconPath: AppIcons.calendar,
                  size: 20,
                  color: Colors.orange,
                ),
                title: 'Maintenance Schedule',
                description: 'Next service due in 2 weeks for Toyota Camry',
                color: Colors.orange,
              ),
              const SizedBox(height: 12),
              _buildInsightCard(
                icon: const CustomIcon(
                  iconPath: AppIcons.wrench,
                  size: 20,
                  color: Colors.blue,
                ),
                title: 'Top Service Type',
                description: 'Oil changes are your most frequent service',
                color: Colors.blue,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cost Trends & Patterns',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Cost Trend Chart
          FutureBuilder<List<ChartDataPoint>>(
            future: _getMonthlyCostData(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                    ),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              return AnalyticsChart(
                title: 'Monthly Maintenance Costs',
                data: snapshot.data!,
                chartType: ChartType.line,
                primaryColor: Theme.of(context).colorScheme.primary,
              );
            },
          ),
          const SizedBox(height: 24),

          // Service Frequency Chart
          FutureBuilder<List<ChartDataPoint>>(
            future: _getServiceTypeData(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                    ),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              return AnalyticsChart(
                title: 'Service Type Distribution',
                data: snapshot.data!,
                chartType: ChartType.pie,
                primaryColor: Theme.of(context).colorScheme.secondary,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownTab() {
    return Consumer2<VehicleProvider, ServiceProvider>(
      builder: (context, vehicleProvider, serviceProvider, child) {
        final vehicles = vehicleProvider.vehicles;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cost Breakdown by Vehicle',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              if (vehicles.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions_car_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No vehicles added yet',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first vehicle to see cost breakdown',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...vehicles.map((vehicle) {
                  return FutureBuilder<List<Service>>(
                    future: serviceProvider.getServicesForVehicleFuture(vehicle.id),
                    builder: (context, snapshot) {
                      final services = snapshot.data ?? [];
                      final totalCost = services.fold<double>(
                        0.0,
                        (sum, service) => sum + service.cost,
                      );

                      if (totalCost == 0) return const SizedBox.shrink();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.directions_car,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${vehicle.year} ${vehicle.make} ${vehicle.model}',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${services.length} service${services.length != 1 ? 's' : ''} • Last service: ${services.isNotEmpty ? Helpers.formatRelativeTime(services.last.serviceDate) : 'N/A'}',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      Helpers.formatCurrency(totalCost),
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                    Text(
                                      'Total spent',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (services.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Recent Services',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        Routes.serviceList,
                                        arguments: vehicle.id,
                                      );
                                    },
                                    child: const Text('View All'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ...services.take(3).map((service) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        service.serviceType.displayName,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ),
                                    Text(
                                      Helpers.formatCurrency(service.cost),
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required Widget icon,
    required Color color,
    required String trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: icon,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trend,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required Widget icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SizedBox(
              width: 20,
              height: 20,
              child: icon,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<List<ChartDataPoint>> _getMonthlyCostData() async {
    final serviceProvider = context.read<ServiceProvider>();
    final services = await serviceProvider.getAllServicesFuture();

    // Group services by month for the last 6 months
    final now = DateTime.now();
    final monthlyData = <String, double>{};

    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      monthlyData[monthKey] = 0.0;
    }

    for (final service in services) {
      final monthKey = '${service.serviceDate.year}-${service.serviceDate.month.toString().padLeft(2, '0')}';
      if (monthlyData.containsKey(monthKey)) {
        monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + service.cost;
      }
    }

    return monthlyData.entries.map((entry) {
      final date = DateTime.parse('${entry.key}-01');
      final monthName = _getMonthName(date.month);
      return ChartDataPoint(
        label: monthName,
        value: entry.value,
      );
    }).toList();
  }

  Future<List<ChartDataPoint>> _getServiceTypeData() async {
    final serviceProvider = context.read<ServiceProvider>();
    final services = await serviceProvider.getAllServicesFuture();

    final typeCount = <String, int>{};
    for (final service in services) {
      typeCount[service.serviceType.displayName] =
          (typeCount[service.serviceType.displayName] ?? 0) + 1;
    }

    final total = services.length.toDouble();
    return typeCount.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      return ChartDataPoint(
        label: entry.key,
        value: percentage,
      );
    }).toList();
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ExportDialog(),
    );
  }

  Widget _buildOfflineAnalytics() {
    return Consumer2<VehicleProvider, ServiceProvider>(
      builder: (context, vehicleProvider, serviceProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.offline_bolt,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Offline Mode',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          Text(
                            'Showing cached data. Some features may be limited.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.orange.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Show cached summary
              _buildOfflineSummary(vehicleProvider, serviceProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOfflineSummary(VehicleProvider vehicleProvider, ServiceProvider serviceProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cached Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildOfflineMetricCard(
                  title: 'Vehicles',
                  value: vehicleProvider.vehicles.length.toString(),
                  icon: Icons.directions_car,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildOfflineMetricCard(
                  title: 'Services',
                  value: serviceProvider.services.length.toString(),
                  icon: Icons.build,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Note: Charts and detailed analytics require internet connection.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
