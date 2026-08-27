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
    // 🔥 ЗАГРУЖАЕМ КОЛИЧЕСТВО ПОЛЬЗОВАТЕЛЕЙ
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

    // 🔥 ЗАГРУЖАЕМ КОЛИЧЕСТВО КЛУБОВ
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

    // 🔥 ПРОВЕРКА ОБНОВЛЕНИЙ — ТОЛЬКО НЕ ДЛЯ ВЕБА!
    try {
      if (!kIsWeb) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            UpdateService.checkForUpdate(context);
          }
        });
      }
    } catch (e) {
      // Игнорируем ошибки обновлений
    }

    // 🔥 ТАЙМЕР 5 СЕКУНД — ВСЕГДА ПЕРЕХОДИМ
    _timer = Timer(const Duration(seconds: 5), _navigateToNext);
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
    final primaryColor = theme.primaryColor;

    return Scaffold(
      body: Stack(
        children: [
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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 150),
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
                const Spacer(), // ← РАЗДВИГАЕТ КОНТЕНТ

                // ============================================================
                // 🔥 КАРТИНКА С ДВУМЯ БЕЙДЖАМИ (СНИЗУ)
                // ============================================================
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 🔥 ОСНОВНАЯ КАРТИНКА
                      Image.asset(
                        'assets/clubs.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),

                      // 🔥 БЕЙДЖ 1: КЛУБЫ (СЛЕВА ВВЕРХУ)
                      Positioned(
                        top: -10,
                        left: -10,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? Colors.black : Colors.white,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${_clubCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 🔥 БЕЙДЖ 2: ПОЛЬЗОВАТЕЛИ (СПРАВА ВВЕРХУ)
                      Positioned(
                        top: -10,
                        right: -10,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? Colors.black : Colors.white,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${_userCount}',
                              style: const TextStyle(
                                color: Colors.white,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
