// lib/application/providers/club_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/services/club_service.dart';

final clubProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final result = await ClubService.getMyClub();
  if (result['success']) {
    final club = result['club'];
    return {
      'id': club['id'],
      'title': club['title'],
      'city': club['city'],
      'description': club['description'],
      'country': club['country'],
      'region': club['region'],
      'logo_url': club['logo_url'],
      'president_id': club['president_id'],
      'president_name': club['president_name'],
      'judges_count': club['judges_count'],
      'is_official': club['is_official'],
      'created_at': club['created_at'],
    };
  }
  return null;
});

final clubRefreshProvider = Provider((ref) => _ClubRefreshNotifier(ref));

class _ClubRefreshNotifier {
  final Ref ref;
  _ClubRefreshNotifier(this.ref);

  void refresh() {
    ref.invalidate(clubProvider);
  }
}