import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:autocare_pro/data/models/service.dart';
import 'package:autocare_pro/presentation/providers/service_provider.dart';

class CostTrendChart extends StatefulWidget {
  const CostTrendChart({super.key});

  @override
  State<CostTrendChart> createState() => _CostTrendChartState();
}

class _CostTrendChartState extends State<CostTrendChart> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceProvider>(
      builder: (context, serviceProvider, child) {
        return FutureBuilder<Map<String, double>>(
          future: _getMonthlyCostData(serviceProvider),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(
                child: Text('Unable to load cost trend data'),
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

  Future<Map<String, double>> _getMonthlyCostData(ServiceProvider serviceProvider) async {
    final allServices = serviceProvider.allServices;

    // Group services by month
    final monthlyData = <String, double>{};

    for (final service in allServices) {
      final monthKey = '${service.serviceDate.year}-${service.serviceDate.month.toString().padLeft(2, '0')}';
      monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + service.cost;
    }

    // Sort by date
    final sortedEntries = monthlyData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Map.fromEntries(sortedEntries);
  }

  Widget _buildChart(Map<String, double> data) {
    final spots = <FlSpot>[];
    final labels = <String>[];

    var index = 0;
    for (final entry in data.entries) {
      spots.add(FlSpot(index.toDouble(), entry.value));
      labels.add(_formatMonthLabel(entry.key));
      index++;
    }

    if (spots.isEmpty) {
      return const Center(
        child: Text('No data to display'),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _calculateInterval(data.values),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[index],
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _calculateInterval(data.values),
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toInt()}',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: spots.length.toDouble() - 1,
        minY: 0,
        maxY: _getMaxY(data.values),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Theme.of(context).colorScheme.primary,
                  strokeWidth: 2,
                  strokeColor: Theme.of(context).colorScheme.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  String _formatMonthLabel(String monthKey) {
    final parts = monthKey.split('-');
    final year = parts[0];
    final month = int.parse(parts[1]);

    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return '${monthNames[month - 1]} ${year.substring(2)}';
  }

  double _calculateInterval(Iterable<double> values) {
    final maxValue = values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);
    if (maxValue <= 100) return 25;
    if (maxValue <= 500) return 100;
    if (maxValue <= 1000) return 250;
    if (maxValue <= 5000) return 1000;
    return (maxValue / 5).roundToDouble();
  }

  double _getMaxY(Iterable<double> values) {
    final maxValue = values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);
    return maxValue * 1.2; // Add 20% padding
  }
}
