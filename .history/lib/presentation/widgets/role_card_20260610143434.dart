import 'package:flutter/material.dart';

class RoleCard extends StatelessWidget {
  final String role;
  final VoidCallback onClose;

  const RoleCard({super.key, required this.role, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.80, // 2/3 ширины экрана
        height: MediaQuery.of(context).size.height * 0.80, // 2/3 высоты экрана
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: AssetImage('assets/$role.png'),
            fit: BoxFit.contain,
          ),
        ),
        child: Stack(
          children: [
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
            // Кнопка закрытия в углу
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: onClose,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
