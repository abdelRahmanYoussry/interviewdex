import 'package:flutter/material.dart';

import '../../features/home/presentation/screens/home_screen.dart';

abstract final class AppRoutes {
  static const home = '/';
}

class AppRouter {
  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute<void>(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      default:
        return null;
    }
  }
}
