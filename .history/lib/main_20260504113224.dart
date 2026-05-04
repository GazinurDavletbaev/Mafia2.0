import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'application/providers/providers.dart';
import 'router/app_router.dart';
import 'core/themes/app_theme.dart';
import 'hive_registrar.g.dart';  // ← сгенерированный файл с адаптерами
import 'data/local/sources/game_local_source.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Hive
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  // Регистрация адаптеров (из сгенерированного файла)
  Hive.registerAdapters();
  
  // Инициализация GameLocalSource
  final gameLocalSource = GameLocalSource();
  await gameLocalSource.init();

  runApp(
    ProviderScope(
      overrides: [
        gameLocalSourceProvider.overrideWithValue(gameLocalSource),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mafia Help',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}