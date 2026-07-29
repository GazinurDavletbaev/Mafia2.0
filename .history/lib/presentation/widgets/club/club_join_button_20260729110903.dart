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

    if (widget.myClubId != null && !isMyClub) {
      return _buildInfoMessage(
        icon: Icons.info_outline,
        text: 'У вас есть клуб',
        color: Colors.orange,
      );
    }

    if (isMyClub) {
      return _buildInfoMessage(
        icon: Icons.check_circle,
        text: '✅ Ваш клуб',
        color: Colors.green,
      );
    }

    if (hasPendingRequest) {
      return _buildInfoMessage(
        icon: Icons.hourglass_top,
        text: '⏳ Заявка отправлена',
        color: Colors.orange,
      );
    }

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

    final result = await ClubService.joinClub(widget.club!['id']);
    
    setState(() => _isLoading = false);

    if (result['success']) {
      widget.onJoin();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Заявка отправлена!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Ошибка'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}