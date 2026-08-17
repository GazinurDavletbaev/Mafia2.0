import 'dart:io';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart'; // 🔥 ДОБАВЬ ЭТУ СТРОКУ (Size, Colors, Offset)

Future<void> initPlatformSpecific() async {
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

    await windowManager.setPosition(const Offset(1500, 100));
  }

  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
}
