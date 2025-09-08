import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:autocare_pro/data/models/service.dart';
import 'package:autocare_pro/presentation/providers/service_provider.dart';

class ServiceTypeChart extends StatefulWidget {
  const ServiceTypeChart({super.key});

  @override
  State<ServiceTypeChart> createState() => _ServiceTypeChartState();
}

class _ServiceTypeChartState extends State<ServiceTypeChart> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceProvider>(
      builder: (context, serviceProvider, child) {
        return FutureBuilder<Map<ServiceType, int>>(
          future: _getServiceTypeData(serviceProvider),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(
                child: Text('Unable to load service type data'),
              );
            }

            final data = snapshot.data!;
            if (data.isEmpty) {
              return const Center(
                child: Text('No service data available'),
              );
            }

            return _buildChart(data);
          },
        );
      },
    );
  }

  Future<Map<ServiceType, int>> _getServiceTypeData(ServiceProvider serviceProvider) async {
    final allServices = serviceProvider.allServices;
    final typeCount = <ServiceType, int>{};

    for (final service in allServices) {
      typeCount[service.serviceType] = (typeCount[service.serviceType] ?? 0) + 1;
    }

    return typeCount;
  }

  Widget _buildChart(Map<ServiceType, int> data) {
    final total = data.values.fold<int>(0, (sum, count) => sum + count);
    final sections = <PieChartSectionData>[];
    var colorIndex = 0;

    final colors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.tertiary,
      Theme.of(context).colorScheme.error,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.brown,
      Colors.indigo,
      Colors.pink,
    ];

    for (final entry in data.entries) {
      final percentage = (entry.value / total) * 100;
      final color = colors[colorIndex % colors.length];

      sections.add(
        PieChartSectionData(
          color: color,
          value: entry.value.toDouble(),
          title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '',
          radius: 80,
          titleStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );

      colorIndex++;
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildLegend(data, total),
        ),
      ],
    );
  }

  Widget _buildLegend(Map<ServiceType, int> data, int total) {
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final colors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.tertiary,
      Theme.of(context).colorScheme.error,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.brown,
      Colors.indigo,
      Colors.pink,
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          entries.length,
          (index) {
            final entry = entries[index];
            final color = colors[index % colors.length];
            final percentage = (entry.value / total) * 100;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key.displayName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${entry.value} services (${percentage.toStringAsFixed(1)}%)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
