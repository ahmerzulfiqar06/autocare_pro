import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:autocare_pro/data/models/service.dart';
import 'package:autocare_pro/presentation/providers/service_provider.dart';

class RecentServicesCard extends StatefulWidget {
  const RecentServicesCard({super.key});

  @override
  State<RecentServicesCard> createState() => _RecentServicesCardState();
}

class _RecentServicesCardState extends State<RecentServicesCard> {
  List<Service> _recentServices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentServices();
  }

  Future<void> _loadRecentServices() async {
    await Future.delayed(Duration.zero); // Ensure context is available
    if (!mounted) return;

    try {
      final serviceProvider = context.read<ServiceProvider>();
      await serviceProvider.loadAllServices();

      if (mounted) {
        setState(() {
          _recentServices = serviceProvider.services
              .take(3) // Show only first 3 recent services
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error loading recent services: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.history,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Recent Services',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Navigate to service history
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_recentServices.isEmpty)
            _buildEmptyState()
          else
            _buildServicesList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.build,
              size: 48,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No services yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add your first service to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentServices.length,
      separatorBuilder: (context, index) => const Divider(height: 16),
      itemBuilder: (context, index) {
        final service = _recentServices[index];
        return Row(
          children: [
            // Service icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getServiceIcon(service.serviceType),
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Service details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.serviceType.displayName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    service.formattedDate,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Cost
            Text(
              service.formattedCost,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getServiceIcon(ServiceType serviceType) {
    switch (serviceType) {
      case ServiceType.oilChange:
        return Icons.oil_barrel;
      case ServiceType.tireRotation:
        return Icons.build;
      case ServiceType.brakeService:
        return Icons.settings;
      case ServiceType.transmissionService:
        return Icons.settings;
      case ServiceType.engineTuneUp:
        return Icons.build;
      case ServiceType.airFilterReplacement:
        return Icons.filter_alt;
      case ServiceType.batteryReplacement:
        return Icons.battery_full;
      case ServiceType.coolantFlush:
        return Icons.water_drop;
      case ServiceType.inspection:
        return Icons.search;
      case ServiceType.other:
        return Icons.build;
    }
  }
}
