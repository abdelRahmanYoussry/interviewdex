import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/analytics/analytics_service.dart';
import 'core/di/services_locator.dart';
import 'features/settings/presentation/settings_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    for (final (family, path) in [
      ('Sora', 'assets/fonts/sora/OFL.txt'),
      ('Inter', 'assets/fonts/inter/OFL.txt'),
      ('JetBrains Mono', 'assets/fonts/jetbrainsmono/OFL.txt'),
      ('IBM Plex Sans Arabic', 'assets/fonts/ibmplexsansarabic/OFL.txt'),
    ]) {
      yield LicenseEntryWithLineBreaks([
        family,
      ], await rootBundle.loadString(path));
    }
  });
  await setupServiceLocator();
  final settingsCubit = sl<SettingsCubit>();
  await settingsCubit.load();
  unawaited(sl<AnalyticsService>().appOpen());
  runApp(App(router: sl(), settingsCubit: settingsCubit));
}
