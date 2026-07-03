// lib/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _logoAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.5),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Логотип
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Align(
                  alignment: Alignment.center,
                  child: SlideTransition(
                    position: _logoAnimation,
                    child: Opacity(
                      opacity: 1 - _fadeAnimation.value * 0.3,
                      child: Image.asset(
                        'assets/mafia_logo.png',
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),
            // Форма входа
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Добро пожаловать!',
                            style: TextStyle(
                              color: theme.textTheme.titleLarge?.color ??
                                  Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Войдите в свой аккаунт',
                            style: TextStyle(
                              color:
                                  isDark ? Colors.grey : Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Email поле
                          TextField(
                            style: TextStyle(
                              color: theme.textTheme.bodyLarge?.color ??
                                  Colors.white,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon:
                                  const Icon(Icons.email, color: Colors.orange),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Пароль
                          TextField(
                            obscureText: true,
                            style: TextStyle(
                              color: theme.textTheme.bodyLarge?.color ??
                                  Colors.white,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Пароль',
                              labelStyle: TextStyle(
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon:
                                  const Icon(Icons.lock, color: Colors.orange),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  Icons.visibility_off,
                                  color: isDark
                                      ? Colors.grey
                                      : Colors.grey.shade600,
                                ),
                                onPressed: () {},
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Забыли пароль?
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Забыли пароль?',
                                style: TextStyle(color: Colors.orange),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Кнопка Войти
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.black,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Войти',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Кнопка "Нет аккаунта? Зарегистрироваться"
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Нет аккаунта?',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey
                                      : Colors.grey.shade600,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.go('/register');
                                },
                                child: const Text(
                                  'Зарегистрироваться',
                                  style: TextStyle(color: Colors.orange),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Разделитель
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: isDark
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade300,
                                  thickness: 0.5,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'или войдите через',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.grey.shade500
                                        : Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: isDark
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade300,
                                  thickness: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Социальные кнопки
                          Row(
                            children: [
                              Expanded(
                                child: _buildSocialButton(
                                  context,
                                  icon: Icons.g_mobiledata,
                                  label: 'Google',
                                  color: Colors.white,
                                  onTap: () {},
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSocialButton(
                                  context,
                                  icon: Icons.language,
                                  label: 'gomafia.pro',
                                  color: Colors.orange,
                                  onTap: () {},
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Войти без регистрации
                          TextButton(
                            onPressed: () {
                              context.go('/club');
                            },
                            child: Text(
                              'Войти без регистрации →',
                              style: TextStyle(
                                color:
                                    isDark ? Colors.grey : Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
