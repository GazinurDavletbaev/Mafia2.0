import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class ResetCodeScreen extends ConsumerStatefulWidget {
  final String email;

  const ResetCodeScreen({super.key, required this.email});

  @override
  ConsumerState<ResetCodeScreen> createState() => _ResetCodeScreenState();
}

class _ResetCodeScreenState extends ConsumerState<ResetCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  bool _isCodeValid = false;
  String? _resetToken;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onCodeChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Если все поля заполнены
    if (_code.length == 6) {
      _verifyCode();
    }
  }

  Future<void> _verifyCode() async {
    if (_code.length < 6) {
      _showSnackBar('Введите все 6 цифр', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.verifyResetCode(
      email: widget.email,
      code: _code,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      _resetToken = result['reset_token'];
      setState(() => _isCodeValid = true);
      _showSnackBar('Код подтверждён!', Colors.green);

      // Переход на экран смены пароля
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          context.push(
            '/reset-password',
            extra: _resetToken,
          );
        }
      });
    } else {
      _showSnackBar(result['error'] ?? 'Неверный код', Colors.red);
      // Очищаем поля
      for (var controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    }
  }

  Future<void> _resendCode() async {
    setState(() => _isLoading = true);

    final result = await AuthService.forgotPassword(email: widget.email);

    setState(() => _isLoading = false);

    if (result['success']) {
      _showSnackBar('Новый код отправлен на почту', Colors.green);
      // Очищаем поля
      for (var controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    } else {
      _showSnackBar(result['error'] ?? 'Ошибка', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Введите код'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sms, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              'Проверьте почту',
              style: TextStyle(
                color: theme.textTheme.titleLarge?.color ?? Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Мы отправили 6-значный код на ${widget.email}',
              style: TextStyle(
                color: isDark ? Colors.grey : Colors.grey.shade600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // 6 полей для ввода кода
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 45,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.orange, width: 2),
                      ),
                    ),
                    onChanged: (value) => _onCodeChanged(index, value),
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),
            Text(
              'Код действует 15 минут',
              style: TextStyle(
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 24),

            // Кнопка Подтвердить
            SizedBox(
              width: double.infinity,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _code.length == 6 ? _verifyCode : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Подтвердить',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 12),

            // Кнопка "Отправить код ещё раз"
            TextButton(
              onPressed: _isLoading ? null : _resendCode,
              child: Text(
                'Отправить код ещё раз',
                style: TextStyle(
                  color: _isLoading ? Colors.grey : Colors.orange,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Кнопка назад
            TextButton(
              onPressed: () => context.go('/forgot-password'),
              child: const Text(
                '← Назад',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}