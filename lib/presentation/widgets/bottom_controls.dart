import 'package:flutter/material.dart';
import 'minimize_button.dart';
import 'phase_nav_button.dart';

class BottomControls extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onForward;

  const BottomControls({
    super.key,
    required this.onBack,
    required this.onForward,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Кнопка НАЗАД
          PhaseNavButton(
            icon: Icons.arrow_back_ios,
            onTap: onBack,
          ),
          
          // Кнопка СВЕРНУТЬ
          const MinimizeButton(),
          
          // Кнопка ВПЕРЁД
          PhaseNavButton(
            icon: Icons.arrow_forward_ios,
            onTap: onForward,
          ),
        ],
      ),
    );
  }
}