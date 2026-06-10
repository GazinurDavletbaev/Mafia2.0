import 'package:flutter/material.dart';

class RoleCard extends StatelessWidget {
  final String role;
  final int seatNumber;
  final VoidCallback onClose;

  const RoleCard(
      {super.key,
      required this.role,
      required this.seatNumber,
      required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.66,
        height: MediaQuery.of(context).size.height * 0.66,
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
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
            // Номер игрока в левом верхнем углу
            // Номер игрока в левом верхнем углу
            Positioned(
              top: 32,
              left: 24,
              child: Container(
                width: 44,
                height: 44,
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
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // Кнопка закрытия в правом верхнем углу
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: onClose,
              ),
            ),
            // Центральная иконка
            Center(
              child: _buildIcon(),
            ),
            // Тап по любой области для закрытия
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

  Color _getBackgroundColor() {
    switch (role) {
      case 'citizen':
        return Colors.red.shade800;
      case 'sheriff':
        return Colors.red.shade800;
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
