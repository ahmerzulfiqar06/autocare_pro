import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:autocare_pro/core/utils/animations.dart';
import 'package:autocare_pro/core/widgets/custom_icon.dart';
import 'package:autocare_pro/data/services/export_service.dart';
import 'package:autocare_pro/data/models/vehicle.dart';
import 'package:autocare_pro/data/models/service.dart';
import 'package:autocare_pro/data/models/service_schedule.dart';
import 'package:autocare_pro/presentation/providers/vehicle_provider.dart';
import 'package:autocare_pro/presentation/providers/service_provider.dart';

class ExportDialog extends StatefulWidget {
  const ExportDialog({super.key});

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> with TickerProviderStateMixin {
  bool _isExporting = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const CustomIcon(
                      iconPath: AppIcons.export,
                      size: 24,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Export Data',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Choose your preferred export format',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Export options
              if (_isExporting)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Preparing your data...'),
                      ],
                    ),
                  ),
                )
              else
                ..._buildExportOptions(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExportOptions() {
    return [
      // CSV Export
      _buildExportOption(
        icon: const CustomIcon(
          iconPath: AppIcons.export,
          size: 24,
          color: Colors.green,
        ),
        title: 'Export as CSV',
        subtitle: 'Spreadsheet format for data analysis',
        color: Colors.green,
        onTap: () => _exportAsCSV(),
      ),
      const SizedBox(height: 16),

      // PDF Report
      _buildExportOption(
        icon: const CustomIcon(
          iconPath: AppIcons.export,
          size: 24,
          color: Colors.red,
        ),
        title: 'Generate PDF Report',
        subtitle: 'Professional report with charts and summaries',
        color: Colors.red,
        onTap: () => _exportAsPDF(),
      ),
      const SizedBox(height: 16),

      // Share Summary
      _buildExportOption(
        icon: const CustomIcon(
          iconPath: AppIcons.export,
          size: 24,
          color: Colors.blue,
        ),
        title: 'Share Summary',
        subtitle: 'Quick overview for sharing',
        color: Colors.blue,
        onTap: () => _shareSummary(),
      ),
      const SizedBox(height: 24),

      // Cancel button
      SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(
            'Cancel',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildExportOption({
    required Widget icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: icon,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportAsCSV() async {
    setState(() => _isExporting = true);

    try {
      final vehicleProvider = context.read<VehicleProvider>();
      final serviceProvider = context.read<ServiceProvider>();

      final vehicles = vehicleProvider.vehicles;
      final services = serviceProvider.services;
      final schedules = serviceProvider.serviceSchedules;

      final exportService = ExportService();
      final file = await exportService.exportToCSV(
        vehicles: vehicles,
        services: services,
        schedules: schedules,
        fileName: 'autocare_data_${DateTime.now().toString().split(' ')[0]}',
      );

      Navigator.of(context).pop();
      await exportService.shareFile(file, 'CSV Export');

      _showSuccessMessage('CSV exported successfully!');
    } catch (e) {
      _showErrorMessage('Failed to export CSV: $e');
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _exportAsPDF() async {
    setState(() => _isExporting = true);

    try {
      final vehicleProvider = context.read<VehicleProvider>();
      final serviceProvider = context.read<ServiceProvider>();

      final vehicles = vehicleProvider.vehicles;
      final services = serviceProvider.services;
      final schedules = serviceProvider.serviceSchedules;

      final exportService = ExportService();
      final file = await exportService.exportToPDF(
        vehicles: vehicles,
        services: services,
        schedules: schedules,
        fileName: 'autocare_report_${DateTime.now().toString().split(' ')[0]}',
      );

      Navigator.of(context).pop();
      await exportService.shareFile(file, 'PDF Report');

      _showSuccessMessage('PDF report generated successfully!');
    } catch (e) {
      _showErrorMessage('Failed to generate PDF: $e');
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _shareSummary() async {
    try {
      final vehicleProvider = context.read<VehicleProvider>();
      final serviceProvider = context.read<ServiceProvider>();

      final vehicles = vehicleProvider.vehicles;
      final services = serviceProvider.services;
      final schedules = serviceProvider.serviceSchedules;

      final exportService = ExportService();
      final summary = exportService.generateSummaryText(
        vehicles: vehicles,
        services: services,
        schedules: schedules,
      );

      Navigator.of(context).pop();

      await Share.share(
        text: summary,
        subject: 'AutoCare Pro - Maintenance Summary',
      );

      _showSuccessMessage('Summary shared successfully!');
    } catch (e) {
      _showErrorMessage('Failed to share summary: $e');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
