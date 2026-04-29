import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    // Запускаем таймер на 3 секунды
    _timer = Timer(const Duration(seconds: 3), _navigateToRegister);
  }

  void _navigateToRegister() {
    if (mounted) {
      context.go('/register');
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
        child: GestureDetector(
          onTap: () {
            // При тапе отменяем таймер и переходим сразу
            _timer?.cancel();
            _navigateToRegister();
          },
          child: Image.asset(
            'assets/mafia.png',
            width: 150,
            height: 150,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}