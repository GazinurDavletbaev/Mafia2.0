import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  int _userCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 🔥 ЗАГРУЖАЕМ КОЛИЧЕСТВО ПОЛЬЗОВАТЕЛЕЙ
    final result = await UserService.getUserCount();
    if (result['success']) {
      setState(() {
        _userCount = result['count'] ?? 0;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }

    // 🔥 ТАЙМЕР НА 2 СЕКУНДЫ
    _timer = Timer(const Duration(seconds: 240), _navigateToNext);
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Colors.black, Colors.grey.shade900]
                : [Colors.white, Colors.grey.shade100],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔥 ЛОГОТИП
              Image.asset(
                'assets/logo_new.png',
                width: 250,
                height: 250,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              // 🔥 НАЗВАНИЕ
              Image.asset(
                'assets/fsmtext.png',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              // 🔥 НАЗВАНИЕ
              Image.asset(
                'assets/fsm.png',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 100),
              // 🔥 СЧЁТЧИК ПОЛЬЗОВАТЕЛЕЙ
              Container(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people,
                      color: primaryColor,
                      size: 20,
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Text(
                      '${_userCount} пользователей',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
