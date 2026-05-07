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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }
}