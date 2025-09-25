import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomIcon extends StatelessWidget {
  final String iconPath;
  final double size;
  final Color? color;
  final String? semanticLabel;

  const CustomIcon({
    super.key,
    required this.iconPath,
    this.size = 24.0,
    this.color,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      iconPath,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
      semanticsLabel: semanticLabel,
      placeholderBuilder: (context) => Icon(
        Icons.help_outline,
        size: size,
        color: color ?? Theme.of(context).colorScheme.primary.withOpacity(0.5),
      ),
      errorBuilder: (context, error, stackTrace) {
        // Log the error for debugging
        debugPrint('Failed to load SVG: $iconPath - Error: $error');
        return Icon(
          Icons.image_not_supported_outlined,
          size: size,
          color: color ?? Theme.of(context).colorScheme.error.withOpacity(0.5),
        );
      },
    );
  }
}

// Icon constants for easy access
class AppIcons {
  // Dashboard
  static const String dashboard = 'assets/icons/dashboard/dashboard_icon.svg';

  // Vehicles
  static const String car = 'assets/icons/vehicles/car_icon.svg';

  // Services
  static const String wrench = 'assets/icons/services/wrench_icon.svg';

  // Analytics
  static const String chart = 'assets/icons/analytics/chart_icon.svg';

  // Settings
  static const String gear = 'assets/icons/settings/gear_icon.svg';

  // Common
  static const String search = 'assets/icons/common/search_icon.svg';
  static const String add = 'assets/icons/common/add_icon.svg';
  static const String notification = 'assets/icons/common/notification_icon.svg';
  static const String calendar = 'assets/icons/common/calendar_icon.svg';
  static const String money = 'assets/icons/common/money_icon.svg';
  static const String filter = 'assets/icons/common/filter_icon.svg';
  static const String export = 'assets/icons/common/export_icon.svg';
  static const String backup = 'assets/icons/common/backup_icon.svg';
}
