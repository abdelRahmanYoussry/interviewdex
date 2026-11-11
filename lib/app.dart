import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({required this.router, super.key});

  final AppRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InterviewDex',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: AppRoutes.home,
      onGenerateRoute: router.onGenerateRoute,
    );
  }
}
