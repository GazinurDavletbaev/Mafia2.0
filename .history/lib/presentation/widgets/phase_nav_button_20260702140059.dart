import 'package:flutter/material.dart';

class PhaseNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const PhaseNavButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white : Colors.black87,
          size: size * 0.5,
        ),
      ),
    );
  }
}