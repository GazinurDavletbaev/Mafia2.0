import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

class MinimizeButton extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const MinimizeButton({
    super.key,
    this.size = 60,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: _minimizeApp,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? Colors.white : Colors.black87,
            width: 2,
          ),
        ),
        child: Icon(
          Icons.minimize,
          color: iconColor ?? (isDark ? Colors.white : Colors.black87),
          size: size * 0.5,
        ),
      ),
    );
  }

  void _minimizeApp() async {
    if (Platform.isLinux || Platform.isWindows) {
      await windowManager.minimize();
    } else {
      debugPrint('Минимизация доступна только на desktop');
    }
  }
}