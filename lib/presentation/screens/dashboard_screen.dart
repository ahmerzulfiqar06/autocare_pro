import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:autocare_pro/config/routes.dart';
import 'package:autocare_pro/core/utils/helpers.dart';
import 'package:autocare_pro/presentation/providers/vehicle_provider.dart';
import 'package:autocare_pro/presentation/providers/service_provider.dart';
import 'package:autocare_pro/presentation/widgets/dashboard_card.dart';
import 'package:autocare_pro/presentation/widgets/recent_services_card.dart';
import 'package:autocare_pro/presentation/widgets/upcoming_services_card.dart';

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
    final vehicleProvider = context.read<VehicleProvider>();
    final serviceProvider = context.read<ServiceProvider>();

    await vehicleProvider.loadVehicles();
    await serviceProvider.loadAllActiveSchedules();
    await serviceProvider.loadAllServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, Routes.settings),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, Routes.addVehicle),
        tooltip: 'Add Vehicle',
        child: const Icon(Icons.add),
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
          children: [
            Expanded(
              child: DashboardCard(
                title: 'Active Vehicles',
                value: activeVehicles.toString(),
                icon: Icons.directions_car,
                color: Theme.of(context).colorScheme.primary,
                onTap: () => Navigator.pushNamed(context, Routes.vehicleList),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FutureBuilder<double>(
                future: serviceProvider.getTotalServiceCostAll(),
                builder: (context, snapshot) {
                  final totalCost = snapshot.data ?? 0.0;
                  return DashboardCard(
                    title: 'Total Spent',
                    value: Helpers.formatCurrency(totalCost),
                    icon: Icons.attach_money,
                    color: Theme.of(context).colorScheme.secondary,
                    onTap: () => Navigator.pushNamed(context, Routes.analytics),
                  );
                },
              ),
            ),
          ],
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
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.directions_car,
                label: 'Add Vehicle',
                onTap: () => Navigator.pushNamed(context, Routes.addVehicle),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.build,
                label: 'Log Service',
                onTap: () => Navigator.pushNamed(context, Routes.addService),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.analytics,
                label: 'Analytics',
                onTap: () => Navigator.pushNamed(context, Routes.analytics),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
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
