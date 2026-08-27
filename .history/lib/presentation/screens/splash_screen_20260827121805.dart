// lib/presentation/screens/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/update_service.dart';
import '../../services/club_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  int _userCount = 0;
  int _clubCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final result = await UserService.getUserCount();
      if (result['success']) {
        setState(() {
          _userCount = result['count'] ?? 0;
        });
      }
    } catch (e) {
      print('⚠️ Не удалось получить количество пользователей: $e');
    }

    try {
      final result = await ClubService.getAllClubs();
      if (result['success']) {
        final clubs = result['clubs'] as List? ?? [];
        setState(() {
          _clubCount = clubs.length;
        });
      }
    } catch (e) {
      print('⚠️ Не удалось получить количество клубов: $e');
    }

    setState(() {
      _isLoading = false;
    });

    try {
      if (!kIsWeb) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            UpdateService.checkForUpdate(context);
          }
        });
      }
    } catch (e) {}

    _timer = Timer(const Duration(seconds: 500), _navigateToNext);
  }

  Future<void> _navigateToNext() async {
    if (!mounted) return;
    final token = await AuthService.getToken();
    if (mounted) {
      if (token != null && token.isNotEmpty) {
        context.go('/lobby');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // ФОН
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [Colors.black, Colors.black]
                    : [Colors.white, Colors.grey.shade100],
              ),
            ),
          ),

          // FSM (правый верхний угол)
          Positioned(
            top: 50,
            right: 20,
            child: Image.asset(
              'assets/fsm.png',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
          ),

          // ЛОГОТИП (центр)
          Positioned(
            top: screenHeight * 0.15,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Image.asset(
                  'assets/logo_new.png',
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                ),
                Image.asset(
                  'assets/fsmtext.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),

          // ============================================================
          // 🔥 КАРТИНКА С ДВУМЯ БЕЙДЖАМИ
          // ============================================================
          Positioned(
            bottom: -90,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ОСНОВНАЯ КАРТИНКА
                  Image.asset(
                    'assets/clubs.png',
                    width: 400,
                    height: 400,
                    fit: BoxFit.contain,
                  ),

                  // БЕЙДЖ 1: КЛУБЫ (СЛЕВА ВВЕРХУ)
                  Positioned(
                    top: 160,
                    left: 100,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.deepPurple.shade300
                            : Colors.pink.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? Colors.black : Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${_clubCount}',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // БЕЙДЖ 2: ПОЛЬЗОВАТЕЛИ (СПРАВА ВВЕРХУ)
                  Positioned(
                    top: 120,
                    right: 130,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.deepPurple.shade300
                            : Colors.pink.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? Colors.black : Colors.red,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${_userCount}',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
