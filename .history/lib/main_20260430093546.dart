import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'models/hive_registrar.g.dart';
import 'hive_registrar.g.dart';  // ← исправленный путь

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Hive для всех платформ
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  // Регистрация всех адаптеров (из сгенерированного файла)
  HiveRegistrar().registerAllAdapters();

  runApp(const MyApp());
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
    );
  }
}
