// lib/presentation/screens/reset_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String? token;

  const ResetPasswordScreen({super.key, this.token});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (password.isEmpty || confirm.isEmpty) {
      _showSnackBar('Заполните все поля', Colors.red);
      return;
    }

    if (password != confirm) {
      _showSnackBar('Пароли не совпадают', Colors.red);
      return;
    }

    if (password.length < 6) {
      _showSnackBar('Пароль должен быть не менее 6 символов', Colors.red);
      return;
    }

    // ✅ Проверяем, есть ли токен
    if (widget.token == null || widget.token!.isEmpty) {
      _showSnackBar('Ошибка: токен не найден', Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    final result = await AuthService.resetPassword(
      token: widget.token!,
      newPassword: password,
    );
    setState(() => _isLoading = false);

    if (result['success']) {
      setState(() => _isSuccess = true);
      _showSnackBar('Пароль успешно изменён!', Colors.green);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) context.go('/login');
      });
    } else {
      _showSnackBar(result['error'] ?? 'Ошибка', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Сброс пароля'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              _isSuccess ? 'Пароль изменён!' : 'Введите новый пароль',
              style: TextStyle(
                color: theme.textTheme.titleLarge?.color ?? Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_isSuccess) ...[
              const SizedBox(height: 16),
              Text(
                'Теперь вы можете войти с новым паролем',
                style: TextStyle(
                  color: isDark ? Colors.grey : Colors.grey.shade600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              const SizedBox(height: 32),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                ),
                decoration: InputDecoration(
                  labelText: 'Новый пароль',
                  labelStyle: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  filled: true,
                  fillColor:
                      isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.lock, color: Colors.orange),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: isDark ? Colors.grey : Colors.grey.shade600,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                ),
                decoration: InputDecoration(
                  labelText: 'Подтвердите пароль',
                  labelStyle: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  filled: true,
                  fillColor:
                      isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon:
                      const Icon(Icons.lock_outline, color: Colors.orange),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: isDark ? Colors.grey : Colors.grey.shade600,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Сменить пароль',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
