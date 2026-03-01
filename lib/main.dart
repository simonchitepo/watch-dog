import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state/watchdog_controller.dart';
import 'ui/app.dart';
import 'ui/theme/watchdog_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    // In production you can forward to Crashlytics/Sentry/etc.
    FlutterError.presentError(details);
  };

  final controller = WatchdogController();
  await controller.init();

  runApp(
    ChangeNotifierProvider.value(
      value: controller,
      child: const WatchdogApp(),
    ),
  );
}

class WatchdogApp extends StatelessWidget {
  const WatchdogApp({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<WatchdogController>();
    return MaterialApp(
      title: 'Watchdog',
      debugShowCheckedModeBanner: false,
      theme: WatchdogTheme.light(),
      darkTheme: WatchdogTheme.dark(),
      themeMode: c.settings.themeMode,
      home: const AppRoot(),
    );
  }
}
