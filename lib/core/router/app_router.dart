import 'package:flutter/material.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const settings = '/settings';
}

class AppRouter {
  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute<void>(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      case AppRoutes.settings:
        return MaterialPageRoute<void>(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );
      default:
        return null;
    }
  }
}
