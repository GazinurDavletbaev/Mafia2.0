import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // ✅ Запускаем таймер на 2 секунды
    _timer = Timer(const Duration(seconds: 2), _navigateToNext);
  }

  Future<void> _navigateToNext() async {
    if (!mounted) return;
    
    // ✅ Проверяем токен
    final token = await AuthService.getToken();
    
    if (mounted) {
      if (token != null && token.isNotEmpty) {
        context.go('/lobby');  // Есть токен → в лобби
      } else {
        context.go('/login');  // Нет токена → на логин
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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/mafia_logo.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}