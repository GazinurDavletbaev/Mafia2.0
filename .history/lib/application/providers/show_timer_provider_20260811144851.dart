// lib/application/providers/show_timer_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🔥 ПРОВАЙДЕР ДЛЯ УПРАВЛЕНИЯ ВИДИМОСТЬЮ ГЛОБАЛЬНОГО ТАЙМЕРА
final showGlobalTimerProvider = StateProvider<bool>((ref) => true);