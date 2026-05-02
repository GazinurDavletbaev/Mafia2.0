import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pie_menu/pie_menu.dart';  // ← ДОБАВИТЬ
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'screens/game_screen.dart';
import 'theme/app_theme.dart';
import 'hive_registrar.g.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  // Регистрация адаптеров
  Hive.registerAdapters();
  
  final storageService = StorageService();
  await storageService.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return PieCanvas(  // ← ОБЕРНУТЬ MaterialApp В PieCanvas

      ),
      child: MaterialApp(
        title: 'Mafia Help',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const GameScreen(),
      ),
    );
  }
}