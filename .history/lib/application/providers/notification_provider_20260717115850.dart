// lib/application/providers/notification_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pendingRequestsProvider = StateProvider<int>((ref) => 0);