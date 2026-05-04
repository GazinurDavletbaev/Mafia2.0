import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:pie_menu/pie_menu.dart';
import 'core/themes/app_theme.dart';
import 'hive_registrar.g.dart';
import 'data/local/sources/game_local_source.dart';
import 'presentation/screens/game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  Hive.registerAdapters();
  
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
    return PieCanvas(
      child: MaterialApp(
        title: 'Mafia Help',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const GameScreen(gameId: 'test_game_id'),
      ),
    );
  }
}