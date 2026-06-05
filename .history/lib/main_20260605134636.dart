import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:window_manager/window_manager.dart';
import 'application/providers/providers.dart';
import 'data/local/sources/game_local_source.dart';
import 'app.dart';
import 'hive_registrar.g.dart';
import 'services/update_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Только для десктопа (Linux/Windows/macOS)
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    const windowWidth = 400.0;
    const windowHeight = 800.0;

    const windowOptions = WindowOptions(
      size: Size(windowWidth, windowHeight),
      center: false,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    await windowManager.setPosition(Offset(1500, 100));
  }

  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

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

class _AppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Проверяем обновления после сборки виджета
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateService.checkForUpdate(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const MyApp();
  }
}