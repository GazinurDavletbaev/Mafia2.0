import 'package:flutter/material.dart';

class RoleCard extends StatelessWidget {
  final String role;
  final int seatNumber;
  final VoidCallback onClose;

  const RoleCard({
    super.key,
    required this.role,
    required this.seatNumber,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = _getBackgroundColor();

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.66,
        height: MediaQuery.of(context).size.height * 0.66,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 24,
              left: 0,
              right: 0,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '$seatNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: onClose,
              ),
            ),
            Center(
              child: _buildIcon(),
            ),
            Positioned.fill(
              child: GestureDetector(
                onTap: onClose,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRoleName() {
    switch (role) {
      case 'citizen':
        return 'Мирный';
      case 'sheriff':
        return 'Шериф';
      case 'mafia':
        return 'Мафия';
      case 'don':
        return 'Дон';
      default:
        return role;
    }
  }

  Color _getBackgroundColor() {
    switch (role) {
      case 'citizen':
        return Colors.re;
      case 'sheriff':
        return Colors.red;
      case 'mafia':
        return Colors.grey.shade900;
      case 'don':
        return Colors.grey.shade900;
      default:
        return Colors.grey.shade800;
    }
  }

  Widget? _buildIcon() {
    switch (role) {
      case 'sheriff':
        return const Icon(
          Icons.star,
          color: Colors.white,
          size: 80,
        );
      case 'don':
        return const Icon(
          Icons.emoji_events,
          color: Colors.white,
          size: 80,
        );
      case 'citizen':
      case 'mafia':
      default:
        return null;
    }
  }
}
