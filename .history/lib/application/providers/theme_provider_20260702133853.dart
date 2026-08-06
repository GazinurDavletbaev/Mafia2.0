// lib/application/providers/theme_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = StateProvider<bool>((ref) => false); // false = светлая, true = тёмная