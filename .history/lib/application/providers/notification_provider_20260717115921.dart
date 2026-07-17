// lib/application/providers/notification_provider.dart
final pendingRequestsProvider = StateProvider<int>((ref) {
  return 0;
});

// Функция обновления
Future<void> refreshPendingRequests(WidgetRef ref) async {
  final result = await ClubService.getPendingRequestsCount();
  if (result['success']) {
    ref.read(pendingRequestsProvider.notifier).state = result['count'] ?? 0;
  }
}