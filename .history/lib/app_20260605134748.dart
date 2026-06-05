import 'package:flutter/material.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:mafia_help/services/update_service.dart';
import 'core/themes/app_theme.dart';
import 'presentation/screens/club_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
    return MaterialApp(
      title: 'Mafia Help',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: PieCanvas(
        child: const ClubScreen(),
      ),
    );
  }
}