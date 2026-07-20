// lib/presentation/screens/email_verify_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/auth_service.dart';

class EmailVerifyScreen extends StatefulWidget {
  final String email;

  const EmailVerifyScreen({super.key, required this.email});

  @override
  State<EmailVerifyScreen> createState() => _EmailVerifyScreenState();
}

class _EmailVerifyScreenState extends State<EmailVerifyScreen> {
  bool _isLoading = false;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _checkVerification();
  }

  Future<void> _checkVerification() async {
    setState(() => _isLoading = true);

    final token = await AuthService.getToken();
    if (token != null) {
      final result = await AuthService.getMe(token);
      if (result['success']) {
        final user = result['user'];
        if (user.isEmailVerified) {
          setState(() {
            _isVerified = true;
            _isLoading = false;
          });
          // ✅ Автоматический переход в лобби
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) context.go('/lobby');
          });
          return;
        }
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Подтверждение email'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _isVerified
                ? _buildVerifiedContent(context)
                : _buildUnverifiedContent(context),
      ),
    );
  }

  Widget _buildVerifiedContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.verified, size: 80, color: Colors.green),
        const SizedBox(height: 16),
        Text(
          'Email подтверждён!',
          style: TextStyle(
            color: Colors.green,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Переходим в приложение...',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildUnverifiedContent(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.email_outlined, size: 64, color: Colors.orange),
        const SizedBox(height: 16),
        Text(
          'Подтвердите email',
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color ?? Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Мы отправили письмо на ${widget.email}',
          style: TextStyle(
            color: isDark ? Colors.grey : Colors.grey.shade600,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text(
          'Перейдите по ссылке в письме, чтобы подтвердить аккаунт.',
          style: TextStyle(
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _checkVerification,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Я подтвердил',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _resendEmail,
          child: const Text(
            'Отправить письмо повторно',
            style: TextStyle(color: Colors.orange),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => context.go('/lobby'),
          child: Text(
            'Пропустить (позже)',
            style: TextStyle(
              color: isDark ? Colors.grey : Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _resendEmail() async {
    setState(() => _isLoading = true);

    final result = await AuthService.sendVerificationEmail(email: widget.email);

    setState(() => _isLoading = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Письмо отправлено повторно'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Ошибка отправки'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
