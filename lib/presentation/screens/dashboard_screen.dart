import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:autocare_pro/core/utils/helpers.dart';
import 'package:autocare_pro/presentation/providers/vehicle_provider.dart';
import 'package:autocare_pro/presentation/providers/service_provider.dart';
import 'package:autocare_pro/presentation/widgets/dashboard_card.dart';
import 'package:autocare_pro/presentation/widgets/recent_services_card.dart';
import 'package:autocare_pro/presentation/widgets/upcoming_services_card.dart';
import 'package:autocare_pro/core/widgets/custom_icon.dart';
import 'package:autocare_pro/core/utils/animations.dart';

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
  static const String search = '/search';
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(Duration.zero); // Ensure context is available
    if (!mounted) return;

    final vehicleProvider = context.read<VehicleProvider>();
    final serviceProvider = context.read<ServiceProvider>();

    try {
      await vehicleProvider.loadVehicles();
      await serviceProvider.loadAllActiveSchedules();
      await serviceProvider.loadAllServices();
    } catch (e) {
      // Handle any loading errors gracefully
      debugPrint('Error loading dashboard data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const CustomIcon(
              iconPath: AppIcons.search,
              size: 20,
            ),
            onPressed: () => Navigator.pushNamed(context, Routes.search),
            tooltip: 'Search',
          ),
          IconButton(
            icon: const CustomIcon(
              iconPath: AppIcons.gear,
              size: 20,
            ),
            onPressed: () => Navigator.pushNamed(context, Routes.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              _buildWelcomeSection(),

              const SizedBox(height: 24),

              // Quick stats cards
              _buildQuickStats(),

              const SizedBox(height: 24),

              // Upcoming services
              const UpcomingServicesCard(),

              const SizedBox(height: 24),

              // Recent services
              const RecentServicesCard(),

              const SizedBox(height: 24),

              // Quick actions
              _buildQuickActions(),
            ],
          ),
        ),
      ),
      floatingActionButton: AppAnimations.scaleIn(
        child: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, Routes.addVehicle),
          tooltip: 'Add Vehicle',
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          child: const CustomIcon(
            iconPath: AppIcons.add,
            size: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Welcome to AutoCare Pro',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Consumer2<VehicleProvider, ServiceProvider>(
      builder: (context, vehicleProvider, serviceProvider, child) {
        final activeVehicles = vehicleProvider.activeVehiclesCount;
        final totalVehicles = vehicleProvider.totalVehiclesCount;

        return Row(
          children: AppAnimations.staggeredList(
            children: [
              Expanded(
                child: AppAnimations.scaleIn(
                  child: DashboardCard(
                    title: 'Active Vehicles',
                    value: activeVehicles.toString(),
                    icon: CustomIcon(
                      iconPath: AppIcons.car,
                      size: 24,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    color: Theme.of(context).colorScheme.primary,
                    onTap: () => Navigator.pushNamed(context, Routes.vehicleList),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppAnimations.scaleIn(
                  child: FutureBuilder<double>(
                    future: serviceProvider.getTotalServiceCostAll(),
                    builder: (context, snapshot) {
                      final totalCost = snapshot.data ?? 0.0;
                      return DashboardCard(
                        title: 'Total Spent',
                        value: Helpers.formatCurrency(totalCost),
                        icon: CustomIcon(
                          iconPath: AppIcons.money,
                          size: 24,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        color: Theme.of(context).colorScheme.secondary,
                        onTap: () => Navigator.pushNamed(context, Routes.analytics),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: AppAnimations.staggeredList(
            children: [
              Expanded(
                child: AppAnimations.bounceIn(
                  child: _buildActionButton(
                    icon: CustomIcon(
                      iconPath: AppIcons.car,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    label: 'Add Vehicle',
                    onTap: () => Navigator.pushNamed(context, Routes.addVehicle),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppAnimations.bounceIn(
                  child: _buildActionButton(
                    icon: CustomIcon(
                      iconPath: AppIcons.wrench,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    label: 'Log Service',
                    onTap: () => Navigator.pushNamed(context, Routes.addService),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppAnimations.bounceIn(
                  child: _buildActionButton(
                    icon: CustomIcon(
                      iconPath: AppIcons.chart,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    label: 'Analytics',
                    onTap: () => Navigator.pushNamed(context, Routes.analytics),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 150),
              scale: 1.0,
              child: icon,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
