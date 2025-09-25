import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:autocare_pro/data/models/service_schedule.dart';
import 'package:autocare_pro/presentation/providers/service_provider.dart';

class UpcomingServicesCard extends StatefulWidget {
  const UpcomingServicesCard({super.key});

  @override
  State<UpcomingServicesCard> createState() => _UpcomingServicesCardState();
}

class _UpcomingServicesCardState extends State<UpcomingServicesCard> {
  List<ServiceSchedule> _upcomingServices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUpcomingServices();
  }

  Future<void> _loadUpcomingServices() async {
    await Future.delayed(Duration.zero); // Ensure context is available
    if (!mounted) return;

    try {
      final serviceProvider = context.read<ServiceProvider>();
      final upcoming = await serviceProvider.getUpcomingServices(daysAhead: 30);
      if (mounted) {
        setState(() {
          _upcomingServices = upcoming.take(3).toList(); // Show only first 3
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error loading upcoming services: $e');
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
                Icons.schedule,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Upcoming Services',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Navigate to full service schedule
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
          else if (_upcomingServices.isEmpty)
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
              Icons.check_circle,
              size: 48,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'All caught up!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'No upcoming services scheduled',
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
      itemCount: _upcomingServices.length,
      separatorBuilder: (context, index) => const Divider(height: 16),
      itemBuilder: (context, index) {
        final schedule = _upcomingServices[index];
        final daysUntil = schedule.daysUntilNextService;

        return Row(
          children: [
            // Service icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getServiceColor(schedule).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getServiceIcon(schedule.serviceType.name),
                color: _getServiceColor(schedule),
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
                    schedule.serviceType.displayName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    schedule.formattedNextServiceDate,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Days indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: daysUntil <= 7
                    ? Theme.of(context).colorScheme.error.withOpacity(0.1)
                    : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                daysUntil <= 0 ? 'Due' : '${daysUntil}d',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: daysUntil <= 7
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getServiceColor(ServiceSchedule schedule) {
    // You can customize colors based on service type
    return Theme.of(context).colorScheme.primary;
  }

  IconData _getServiceIcon(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'oil change':
        return Icons.oil_barrel;
      case 'tire rotation':
        return Icons.build;
      case 'brake service':
        return Icons.settings;
      case 'transmission service':
        return Icons.settings;
      case 'engine tune-up':
        return Icons.build;
      case 'air filter replacement':
        return Icons.filter_alt;
      case 'battery replacement':
        return Icons.battery_full;
      case 'coolant flush':
        return Icons.water_drop;
      case 'inspection':
        return Icons.search;
      default:
        return Icons.build;
    }
  }
}
