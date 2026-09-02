import 'package:flutter/material.dart';

class SimpleClubTip extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onClose;

  const SimpleClubTip({
    super.key,
    required this.title,
    required this.description,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 180, // Фиксированная высота, чтобы не было overflow
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Сама карточка с тенью
          Container(
            width: 260,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.group_add, color: Colors.purple, size: 28),
                    GestureDetector(
                      onTap: onClose,
                      child:
                          const Icon(Icons.close, size: 18, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.grey, height: 1.4),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: onClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Попробовать',
                        style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),

          // 2. Плавный хвостик (вниз-вправо)
          Positioned(
            bottom: 0,
            right: 20,
            child: CustomPaint(
              size: const Size(40, 40),
              painter: _SmoothTailPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

// Минимальный пейнтер для красивого хвостика
class _SmoothTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    // Рисуем плавную каплю/хвостик
    path.moveTo(0, 0);
    path.quadraticBezierTo(
        size.width * 0.2, size.height * 0.8, size.width, size.height);
    path.quadraticBezierTo(
        size.width * 0.8, size.height * 0.2, size.width * 0.4, 0);
    path.close();

    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
