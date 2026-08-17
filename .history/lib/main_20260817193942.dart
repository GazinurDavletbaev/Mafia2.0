import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:mafia_help/application/navigation/app_router.dart';
import 'package:mafia_help/core/themes/app_theme.dart';
import 'package:mafia_help/data/local/sources/game_local_source.dart';
import 'package:mafia_help/hive_registrar.g.dart';
import 'package:mafia_help/core/platform/platform_init.dart';
import 'application/providers/providers.dart';
import 'application/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 На вебе — stub (ничего), на десктопе — окно + Hive.init(путь)
  await initPlatformSpecific();

  Hive.registerAdapters();

  final gameLocalSource = GameLocalSource();
  await gameLocalSource.init();

  runApp(
    ProviderScope(
      overrides: [gameLocalSourceProvider.overrideWithValue(gameLocalSource)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Mafia Help',
      routerConfig: router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Stack(
          children: [
            child!,
          ],
        );
      },
    );
  }
}
