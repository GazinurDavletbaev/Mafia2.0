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
    final bool isMyClub = widget.myClubId == currentClubId;
    final bool hasPendingRequest = widget.club?['has_pending_request'] ?? false;
    final bool userHasClub = widget.myClubId != null;

    // 🔥 Если пользователь уже в этом клубе
    if (isMyClub) {
      return _buildInfoMessage(
        icon: Icons.check_circle,
        text: '✅ Ваш клуб',
        color: Colors.green,
      );
    }

    // 🔥 Если пользователь в другом клубе
    if (userHasClub && !isMyClub) {
      return _buildInfoMessage(
        icon: Icons.info_outline,
        text: 'Вы уже в другом клубе',
        color: Colors.orange,
      );
    }

    // 🔥 Если заявка уже отправлена
    if (hasPendingRequest) {
      return _buildInfoMessage(
        icon: Icons.hourglass_top,
        text: '⏳ Заявка отправлена',
        color: Colors.orange,
      );
    }

    // 🔥 Кнопка подачи заявки
    return ElevatedButton(
      onPressed: _isLoading ? null : _joinClub,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        minimumSize: const Size(double.infinity, 0),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text(
              '📩 Подать заявку',
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
    setState(() => _isLoading = true);

    try {
      final result = await ClubService.joinClub(widget.club!['id']);

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (result['success']) {
        // ✅ Заявка отправлена успешно
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

        // 🔥 Проверяем, может быть пользователь уже в клубе
        if (error.contains('already') || error.contains('already in club')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ℹ️ Вы уже состоите в клубе'),
              backgroundColor: Colors.orange,
            ),
          );
          widget.onJoin(); // Обновляем состояние
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // 🚨 Ошибка соединения или другая техническая ошибка
      setState(() => _isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              '⚠️ Заявка не может быть отправлена по техническим причинам. Проверьте подключение к интернету.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }
}
