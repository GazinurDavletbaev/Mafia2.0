import 'package:flutter/material.dart';
import 'package:mafia_help/services/club_service.dart';

class ClubJoinButton extends StatefulWidget {
  final Map<String, dynamic>? club;
  final int? myClubId;
  final VoidCallback onJoin;

  const ClubJoinButton({
    super.key,
    required this.club,
    required this.myClubId,
    required this.onJoin,
  });

  @override
  State<ClubJoinButton> createState() => _ClubJoinButtonState();
}

class _ClubJoinButtonState extends State<ClubJoinButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final int? currentClubId = widget.club?['id'];

    // Статусы
    final bool isMyClub = widget.myClubId == currentClubId;
    final bool userHasClub = widget.myClubId != null;
    final bool hasPendingRequest = widget.club?['has_pending_request'] ?? false;

    // 1️⃣ Если это мой клуб
    if (isMyClub) {
      return _buildInfoMessage(
        icon: Icons.check_circle,
        text: '✅ Ваш клуб',
        color: Colors.green,
      );
    }

    // 2️⃣ Если заявка уже отправлена
    if (hasPendingRequest) {
      return _buildInfoMessage(
        icon: Icons.hourglass_top,
        text: '⏳ Заявка отправлена',
        color: Colors.orange,
      );
    }

    // 3️⃣ Кнопка всегда активна
    return ElevatedButton(
      onPressed: _isLoading ? null : _joinClub,
      boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text(
              'Подать заявку',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Widget _buildInfoMessage({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _joinClub() async {
    final int? currentClubId = widget.club?['id'];
    final bool userHasClub = widget.myClubId != null;

    // 🔥 Проверяем, есть ли у пользователя клуб
    if (userHasClub) {
      // Уже в другом клубе
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'ℹ️ Вы уже состоите в другом клубе. Выйдите из него, чтобы подать заявку.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // 🔥 Проверяем, есть ли активная заявка
    final hasPendingRequest = widget.club?['has_pending_request'] ?? false;
    if (hasPendingRequest) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⏳ Вы уже отправили заявку в этот клуб'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // 🔥 Отправляем заявку
    setState(() => _isLoading = true);

    try {
      final result = await ClubService.joinClub(currentClubId!);

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (result['success']) {
        // ✅ Заявка отправлена
        widget.onJoin();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Заявка отправлена!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // ❌ Ошибка от сервера
        final error = result['error'] ?? 'Неизвестная ошибка';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // 🚨 Техническая ошибка
      setState(() => _isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Ошибка соединения. Проверьте интернет.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }
}
