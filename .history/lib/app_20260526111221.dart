import 'package:flutter/material.dart';
import 'package:pie_menu/pie_menu.dart';
import 'core/themes/app_theme.dart';
import 'presentation/screens/club_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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