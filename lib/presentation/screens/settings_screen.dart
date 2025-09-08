import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:autocare_pro/core/utils/helpers.dart';
import 'package:autocare_pro/presentation/providers/app_provider.dart';
import 'package:autocare_pro/presentation/providers/vehicle_provider.dart';
import 'package:autocare_pro/presentation/providers/service_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Preferences Section
            _buildSectionHeader('App Preferences'),
            const SizedBox(height: 8),
            _buildAppPreferencesSection(),
            const SizedBox(height: 24),

            // Data Management Section
            _buildSectionHeader('Data Management'),
            const SizedBox(height: 8),
            _buildDataManagementSection(),
            const SizedBox(height: 24),

            // Support Section
            _buildSectionHeader('Support'),
            const SizedBox(height: 8),
            _buildSupportSection(),
            const SizedBox(height: 24),

            // About Section
            _buildSectionHeader('About'),
            const SizedBox(height: 8),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildAppPreferencesSection() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              // Theme Toggle
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Toggle between light and dark themes'),
                value: appProvider.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  appProvider.toggleTheme();
                },
              ),
              const Divider(height: 1),

              // Notifications Toggle (placeholder)
              SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive reminders for upcoming services'),
                value: false, // TODO: Implement actual notification settings
                onChanged: (value) {
                  Helpers.showInfoSnackBar(
                    context,
                    'Notification settings coming soon!',
                  );
                },
              ),
              const Divider(height: 1),

              // Currency Settings
              ListTile(
                title: const Text('Currency'),
                subtitle: const Text('USD'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Helpers.showInfoSnackBar(
                    context,
                    'Currency settings coming soon!',
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDataManagementSection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          // Export Data
          ListTile(
            leading: Icon(
              Icons.download,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Export Data'),
            subtitle: const Text('Download your data as JSON'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _exportData(),
          ),
          const Divider(height: 1),

          // Import Data
          ListTile(
            leading: Icon(
              Icons.upload,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: const Text('Import Data'),
            subtitle: const Text('Import data from backup file'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _importData(),
          ),
          const Divider(height: 1),

          // Clear All Data
          ListTile(
            leading: Icon(
              Icons.delete_forever,
              color: Theme.of(context).colorScheme.error,
            ),
            title: const Text('Clear All Data'),
            subtitle: const Text('Permanently delete all data'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _clearAllData(),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          // Help & FAQ
          ListTile(
            leading: Icon(
              Icons.help_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Help & FAQ'),
            subtitle: const Text('Get help and find answers'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showHelpDialog(),
          ),
          const Divider(height: 1),

          // Contact Support
          ListTile(
            leading: Icon(
              Icons.contact_support,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: const Text('Contact Support'),
            subtitle: const Text('Get in touch with our team'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showContactDialog(),
          ),
          const Divider(height: 1),

          // Rate App
          ListTile(
            leading: Icon(
              Icons.star_outline,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            title: const Text('Rate App'),
            subtitle: const Text('Leave a review on the app store'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _rateApp(),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          // App Version
          ListTile(
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
            trailing: const Icon(Icons.info_outline, size: 16),
          ),
          const Divider(height: 1),

          // Privacy Policy
          ListTile(
            title: const Text('Privacy Policy'),
            subtitle: const Text('Learn how we protect your data'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showPrivacyPolicy(),
          ),
          const Divider(height: 1),

          // Terms of Service
          ListTile(
            title: const Text('Terms of Service'),
            subtitle: const Text('Read our terms and conditions'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showTermsOfService(),
          ),
          const Divider(height: 1),

          // Open Source Licenses
          ListTile(
            title: const Text('Open Source Licenses'),
            subtitle: const Text('Third-party software licenses'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showLicenses(),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    Helpers.showInfoSnackBar(
      context,
      'Data export feature coming soon!',
    );
  }

  void _importData() {
    Helpers.showInfoSnackBar(
      context,
      'Data import feature coming soon!',
    );
  }

  void _clearAllData() async {
    final confirmed = await Helpers.showConfirmationDialog(
      context,
      title: 'Clear All Data',
      message: 'This will permanently delete all your vehicles and service records. This action cannot be undone.',
      confirmText: 'Clear All Data',
      confirmColor: Theme.of(context).colorScheme.error,
    );

    if (confirmed == true) {
      try {
        final vehicleProvider = context.read<VehicleProvider>();
        final serviceProvider = context.read<ServiceProvider>();

        await vehicleProvider.clearAllData();
        await serviceProvider.clearAllData();

        if (mounted) {
          Helpers.showSuccessSnackBar(context, 'All data cleared successfully');
        }
      } catch (e) {
        if (mounted) {
          Helpers.showErrorSnackBar(context, 'Failed to clear data');
        }
      }
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & FAQ'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Frequently Asked Questions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('Q: How do I add a new vehicle?\nA: Go to the dashboard and tap the "+" button.'),
              SizedBox(height: 12),
              Text('Q: How do I log a service?\nA: Open a vehicle details page and tap "Add Service".'),
              SizedBox(height: 12),
              Text('Q: How do I view analytics?\nA: Tap the analytics button on the dashboard.'),
              SizedBox(height: 12),
              Text('Q: How do I backup my data?\nA: Use the Export Data option in Settings.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('For support, please email:'),
            SizedBox(height: 8),
            Text(
              'support@autocarepro.com',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _rateApp() {
    Helpers.showInfoSnackBar(
      context,
      'App rating feature coming soon!',
    );
  }

  void _showPrivacyPolicy() {
    Helpers.showInfoSnackBar(
      context,
      'Privacy policy coming soon!',
    );
  }

  void _showTermsOfService() {
    Helpers.showInfoSnackBar(
      context,
      'Terms of service coming soon!',
    );
  }

  void _showLicenses() {
    showLicensePage(
      context: context,
      applicationName: 'AutoCare Pro',
      applicationVersion: '1.0.0',
    );
  }
}
