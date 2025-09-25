import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:autocare_pro/core/utils/animations.dart';

class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _isOnline = false;
  bool _showOfflineBanner = false;

  ConnectivityResult get connectionStatus => _connectionStatus;
  bool get isOnline => _isOnline;
  bool get showOfflineBanner => _showOfflineBanner;

  // Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check initial connectivity
    _connectionStatus = await Connectivity().checkConnectivity();
    _updateConnectionStatus(_connectionStatus);

    // Listen to connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final wasOnline = _isOnline;
    _connectionStatus = result;
    _isOnline = result != ConnectivityResult.none;

    // Show offline banner when going offline
    if (wasOnline && !_isOnline) {
      _showOfflineBanner = true;
      _hideOfflineBannerAfterDelay();
    }

    notifyListeners();
  }

  // Hide offline banner after a delay
  void _hideOfflineBannerAfterDelay() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _showOfflineBanner = false;
        notifyListeners();
      }
    });
  }

  // Dismiss offline banner manually
  void dismissOfflineBanner() {
    _showOfflineBanner = false;
    notifyListeners();
  }

  // Get user-friendly connectivity status text
  String getConnectionStatusText() {
    switch (_connectionStatus) {
      case ConnectivityResult.wifi:
        return 'Connected to Wi-Fi';
      case ConnectivityResult.mobile:
        return 'Connected to Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Connected to Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Connected to Bluetooth';
      case ConnectivityResult.none:
        return 'No Internet Connection';
      default:
        return 'Unknown Connection Status';
    }
  }

  // Get connectivity status icon
  IconData getConnectionStatusIcon() {
    if (_isOnline) {
      switch (_connectionStatus) {
        case ConnectivityResult.wifi:
          return Icons.wifi;
        case ConnectivityResult.mobile:
          return Icons.signal_cellular_alt;
        case ConnectivityResult.ethernet:
          return Icons.computer;
        default:
          return Icons.network_check;
      }
    } else {
      return Icons.signal_wifi_off;
    }
  }

  // Get connectivity status color
  Color getConnectionStatusColor(BuildContext context) {
    if (_isOnline) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}

// Offline banner widget
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: const Offset(0, -1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.signal_wifi_off,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'You\'re offline. Some features may be limited.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                // Dismiss banner
                final connectivityService = ConnectivityService();
                connectivityService.dismissOfflineBanner();
              },
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}

// Connection status indicator widget
class ConnectionStatusIndicator extends StatelessWidget {
  const ConnectionStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivityService, child) {
        if (!connectivityService.isOnline) {
          return const OfflineBanner();
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// Offline-aware widget wrapper
class OfflineAwareWrapper extends StatelessWidget {
  final Widget child;
  final Widget? offlineWidget;
  final bool showOfflineMessage;

  const OfflineAwareWrapper({
    super.key,
    required this.child,
    this.offlineWidget,
    this.showOfflineMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivityService, child) {
        if (!connectivityService.isOnline && showOfflineMessage) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.signal_wifi_off,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'You\'re Offline',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please check your internet connection to access this feature.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (offlineWidget != null) ...[
                  const SizedBox(height: 24),
                  offlineWidget!,
                ],
              ],
            ),
          );
        }

        return child;
      },
    );
  }
}

// Cached data manager for offline support
class CachedDataManager {
  static const String _cachePrefix = 'autocare_cache_';
  static const Duration _cacheDuration = Duration(hours: 24);

  // Cache data with timestamp
  static Future<void> cacheData(String key, Map<String, dynamic> data) async {
    try {
      // In a real app, you'd use a proper caching mechanism
      // For this demo, we'll use simple in-memory caching
      // In production, consider using shared_preferences or a database
    } catch (e) {
      print('Failed to cache data: $e');
    }
  }

  // Retrieve cached data
  static Future<Map<String, dynamic>?> getCachedData(String key) async {
    try {
      // In a real app, you'd check timestamps and validity
      // For this demo, we'll return null to indicate no cached data
      return null;
    } catch (e) {
      print('Failed to retrieve cached data: $e');
      return null;
    }
  }

  // Clear expired cache
  static Future<void> clearExpiredCache() async {
    try {
      // In a real app, you'd implement cache cleanup logic
      print('Cache cleanup completed');
    } catch (e) {
      print('Failed to clear cache: $e');
    }
  }
}
