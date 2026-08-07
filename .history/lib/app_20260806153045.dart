import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/navigation/app_router.dart';
import 'package:mafia_help/application/providers/theme_provider.dart';
import 'package:mafia_help/presentation/widgets/timer/global_timer_overlay.dart';
import 'core/themes/app_theme.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Mafia Help',
      routerConfig: router,
      theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            const GlobalTimerOverlay(),
          ],
        );
      },
    );
  }
}