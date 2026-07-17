// lib/application/providers/notification_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/club_service.dart';
import 'club_provider.dart';

final pendingRequestsProvider = FutureProvider<int>((ref) async {
  // ✅ Подписываемся на изменения клуба
  ref.watch(clubProvider);
  
  try {
    final result = await ClubService.getPendingRequestsCount();
    print('📦 pendingRequestsProvider result: $result');
    if (result['success']) {
      return result['count'] ?? 0;
    }
    return 0;
  } catch (e) {
    print('❌ pendingRequestsProvider error: $e');
    return 0;
  }
});