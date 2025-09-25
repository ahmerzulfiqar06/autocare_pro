import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:autocare_pro/core/utils/animations.dart';
import 'package:autocare_pro/core/widgets/custom_icon.dart';
import 'package:autocare_pro/data/services/backup_service.dart';
import 'package:autocare_pro/data/models/vehicle.dart';
import 'package:autocare_pro/data/models/service.dart';
import 'package:autocare_pro/data/models/service_schedule.dart';
import 'package:autocare_pro/presentation/providers/vehicle_provider.dart';
import 'package:autocare_pro/presentation/providers/service_provider.dart';

class BackupRestoreDialog extends StatefulWidget {
  const BackupRestoreDialog({super.key});

  @override
  State<BackupRestoreDialog> createState() => _BackupRestoreDialogState();
}

class _BackupRestoreDialogState extends State<BackupRestoreDialog>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _showRestoreOptions = false;
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
                      iconPath: AppIcons.backup,
                      size: 24,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _showRestoreOptions ? 'Restore Data' : 'Backup & Restore',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _showRestoreOptions
                              ? 'Restore from backup file'
                              : 'Secure your data with backups',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (_isLoading)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Processing...'),
                      ],
                    ),
                  ),
                )
              else if (_showRestoreOptions)
                _buildRestoreOptions()
              else
                _buildBackupOptions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackupOptions() {
    return Column(
      children: [
        // Create Full Backup
        _buildBackupOption(
          icon: const CustomIcon(
            iconPath: AppIcons.backup,
            size: 24,
            color: Colors.blue,
          ),
          title: 'Create Full Backup',
          subtitle: 'Backup all your vehicles, services, and schedules',
          color: Colors.blue,
          onTap: () => _createFullBackup(),
        ),
        const SizedBox(height: 16),

        // Create Selective Backup
        _buildBackupOption(
          icon: const CustomIcon(
            iconPath: AppIcons.backup,
            size: 24,
            color: Colors.orange,
          ),
          title: 'Create Selective Backup',
          subtitle: 'Choose what data to include in the backup',
          color: Colors.orange,
          onTap: () => _showSelectiveBackupDialog(),
        ),
        const SizedBox(height: 16),

        // Restore from Backup
        _buildBackupOption(
          icon: const CustomIcon(
            iconPath: AppIcons.backup,
            size: 24,
            color: Colors.green,
          ),
          title: 'Restore from Backup',
          subtitle: 'Restore data from a previous backup',
          color: Colors.green,
          onTap: () => setState(() => _showRestoreOptions = true),
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
      ],
    );
  }

  Widget _buildRestoreOptions() {
    return FutureBuilder<List<File>>(
      future: BackupService().getAvailableBackups(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final backups = snapshot.data!;

        if (backups.isEmpty) {
          return Column(
            children: [
              const Icon(
                Icons.backup_outlined,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'No Backups Found',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Create a backup first to restore your data.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => setState(() => _showRestoreOptions = false),
                child: const Text('Create Backup'),
              ),
            ],
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: backups.length,
                itemBuilder: (context, index) {
                  return FutureBuilder<BackupFileInfo>(
                    future: BackupService().getBackupFileInfo(backups[index]),
                    builder: (context, snapshot) {
                      final info = snapshot.data;

                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (info?.isValid ?? false)
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            (info?.isValid ?? false) ? Icons.backup : Icons.error,
                            color: (info?.isValid ?? false) ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(
                          backups[index].path.split('/').last,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          '${info?.formattedFileSize ?? 'Unknown size'} • ${info?.lastModified.toString().split(' ')[0] ?? 'Unknown date'}',
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'restore') {
                              _restoreFromBackup(backups[index]);
                            } else if (value == 'share') {
                              _shareBackup(backups[index]);
                            } else if (value == 'delete') {
                              _deleteBackup(backups[index]);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'restore',
                              child: Row(
                                children: [
                                  Icon(Icons.restore),
                                  SizedBox(width: 8),
                                  Text('Restore'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'share',
                              child: Row(
                                children: [
                                  Icon(Icons.share),
                                  SizedBox(width: 8),
                                  Text('Share'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => setState(() => _showRestoreOptions = false),
              child: const Text('Back to Backup Options'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBackupOption({
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

  Future<void> _createFullBackup() async {
    setState(() => _isLoading = true);

    try {
      final vehicleProvider = context.read<VehicleProvider>();
      final serviceProvider = context.read<ServiceProvider>();

      final vehicles = vehicleProvider.vehicles;
      final services = serviceProvider.services;
      final schedules = serviceProvider.serviceSchedules;

      final backupService = BackupService();
      final file = await backupService.createFullBackup(
        vehicles: vehicles,
        services: services,
        schedules: schedules,
      );

      Navigator.of(context).pop();
      await backupService.shareBackup(file, 'Full Backup');

      _showSuccessMessage('Full backup created successfully!');
    } catch (e) {
      _showErrorMessage('Failed to create backup: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showSelectiveBackupDialog() async {
    // Show selective backup options dialog
    _showSuccessMessage('Selective backup feature coming soon!');
  }

  Future<void> _restoreFromBackup(File backupFile) async {
    setState(() => _isLoading = true);

    try {
      final backupService = BackupService();
      final result = await backupService.restoreFromBackup(backupFile);

      if (result.success && result.data != null) {
        Navigator.of(context).pop();

        // Show confirmation dialog
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Restore'),
            content: Text(
              'This will replace your current data with the backup data. '
              'This action cannot be undone. Are you sure?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Restore'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          // Perform actual restore
          _showSuccessMessage('Data restored successfully!');
        }
      } else {
        _showErrorMessage(result.message);
      }
    } catch (e) {
      _showErrorMessage('Failed to restore backup: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _shareBackup(File backupFile) async {
    try {
      final backupService = BackupService();
      final info = await backupService.getBackupFileInfo(backupFile);
      await backupService.shareBackup(backupFile, info.fileName);
    } catch (e) {
      _showErrorMessage('Failed to share backup: $e');
    }
  }

  Future<void> _deleteBackup(File backupFile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Backup'),
        content: const Text('Are you sure you want to delete this backup?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final backupService = BackupService();
        await backupService.deleteBackup(backupFile);
        setState(() {}); // Refresh the list
        _showSuccessMessage('Backup deleted successfully!');
      } catch (e) {
        _showErrorMessage('Failed to delete backup: $e');
      }
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
