import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:mafia_help/application/navigation/app_router.dart';
import 'package:mafia_help/core/themes/app_theme.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:window_manager/window_manager.dart';
import 'package:uni_links/uni_links.dart';
import 'application/providers/providers.dart';
import 'application/providers/theme_provider.dart';
import 'data/local/sources/game_local_source.dart';
import 'app.dart';
import 'hive_registrar.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  // ✅ ИНИЦИАЛИЗАЦИЯ ГЛУБОКИХ ССЫЛОК
  await initUniLinks();

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
    );
  }
}

// ✅ ФУНКЦИЯ ДЛЯ ОБРАБОТКИ ГЛУБОКИХ ССЫЛОК
Future<void> initUniLinks() async {
  // Десктоп — пропускаем
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    print('🖥️ Десктоп: app_links не поддерживается');
    return;
  }

  try {
    final appLinks = AppLinks();

    // Получаем ссылку при запуске
    final initialLink = await appLinks.getInitialLink();
    if (initialLink != null) {
      _handleIncomingLink(initialLink);
    }

    // Подписываемся на ссылки
    appLinks.linkStream.listen((String link) {
      _handleIncomingLink(link);
    }, onError: (err) {
      print('❌ Ошибка в linkStream: $err');
    });
  } catch (e) {
    print('❌ Ошибка app_links: $e');
  }
}

// ✅ ОБРАБОТЧИК ССЫЛОК
void _handleIncomingLink(String link) {
  final uri = Uri.parse(link);
  print('🔗 Получена ссылка: $link');

  if (uri.host == 'reset-password') {
    final token = uri.queryParameters['token'];
    print('🔑 Сброс пароля, токен: $token');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState?.pushNamed(
        '/reset-password',
        arguments: token,
      );
    });
  } else if (uri.host == 'verify-email') {
    final token = uri.queryParameters['token'];
    print('🔑 Подтверждение email, токен: $token');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState?.pushNamed(
        '/verify-email',
        arguments: token,
      );
    });
  }
}
