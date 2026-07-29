// lib/presentation/widgets/app_text.dart
import 'package:flutter/material.dart';

class AppText {
  // ====== ЗАГОЛОВКИ ======
  static TextStyle headline1({required bool isDark}) {
    return TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: isDark ? Colors.white : Colors.black87,
    );
  }

  static TextStyle headline2({required bool isDark}) {
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: isDark ? Colors.white : Colors.black87,
    );
  }

  static TextStyle headline3({required bool isDark}) {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: isDark ? Colors.white : Colors.black87,
    );
  }

  // ====== НАЗВАНИЯ (18px, жирный) ======
  static TextStyle title({required bool isDark}) {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: isDark ? Colors.white : Colors.black87,
    );
  }

  // ====== ПОДЗАГОЛОВКИ (16px, полужирный) ======
  static TextStyle subtitle({required bool isDark}) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: isDark ? Colors.white : Colors.black87,
    );
  }

  // ====== ОСНОВНОЙ ТЕКСТ (14px) ======
  static TextStyle body({required bool isDark}) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: isDark ? Colors.white : Colors.black87,
    );
  }

  // ====== МАЛЕНЬКИЙ ТЕКСТ (12px, серый) ======
  static TextStyle small({required bool isDark}) {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: isDark ? Colors.grey : Colors.grey.shade600,
    );
  }

  // ====== ОРАНЖЕВЫЙ АКЦЕНТ ======
  static TextStyle accent({required bool isDark}) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.orange,
    );
  }

  // ====== КНОПКИ (16px, жирный) ======
  static TextStyle button({required bool isDark}) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: isDark ? Colors.white : Colors.black87,
    );
  }
}