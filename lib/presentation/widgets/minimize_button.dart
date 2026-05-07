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
    return GestureDetector(
      onTap: _minimizeApp,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.grey.shade800,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Icon(
          Icons.minimize,
          color: iconColor ?? Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }

  void _minimizeApp() async {
    if (Platform.isLinux || Platform.isWindows) {
      await windowManager.minimize();
    } else {
      // Для мобильных — ничего не делаем или показываем подсказку
      debugPrint('Минимизация доступна только на desktop');
    }
  }
}