import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/services_locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  runApp(App(router: sl()));
}
