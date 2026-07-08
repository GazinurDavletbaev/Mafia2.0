// lib/presentation/screens/club_requests_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/club_service.dart';

class ClubRequestsScreen extends ConsumerStatefulWidget {
  const ClubRequestsScreen({super.key});

  @override
  ConsumerState<ClubRequestsScreen> createState() => _ClubRequestsScreenState();
}

class _ClubRequestsScreenState extends ConsumerState<ClubRequestsScreen> {
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;
  Map<String, dynamic>? _club;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Получаем текущий клуб
    final clubResult = await ClubService.getCurrentClub();
    if (clubResult['success'] && clubResult['club'] != null) {
      _club = clubResult['club'];
      final requestsResult = await ClubService.getClubRequests(_club!['id']);
      if (requestsResult['success']) {
        _requests = (requestsResult['requests'] as List? ?? [])
            .cast<Map<String, dynamic>>();
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _handleRequest(int requestId, String action) async {
    final result = action == 'approve'
        ? await ClubService.approveRequest(requestId)
        : await ClubService.rejectRequest(requestId);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(action == 'approve' ? 'Заявка принята' : 'Заявка отклонена'),
          backgroundColor: action == 'approve' ? Colors.green : Colors.red,
        ),
      );
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Ошибка'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_club != null ? 'Заявки в "${_club!['title']}"' : 'Заявки'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox,
                        size: 64,
                        color: isDark
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Нет активных заявок',
                        style: TextStyle(
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Здесь будут отображаться заявки на вступление в ваш клуб',
                        style: TextStyle(
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade500,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final request = _requests[index];
                    return Card(
                      color: isDark ? Colors.grey.shade800 : Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange.shade100,
                          child: Text(
                            request['username']
                                    ?.substring(0, 1)
                                    .toUpperCase() ??
                                '?',
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                        title: Text(
                          request['username'] ?? 'Неизвестен',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.bodyLarge?.color ??
                                Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          request['email'] ?? '',
                          style: TextStyle(
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.check, color: Colors.green),
                              onPressed: () =>
                                  _handleRequest(request['id'], 'approve'),
                              tooltip: 'Принять',
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.green.withOpacity(0.1),
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () =>
                                  _handleRequest(request['id'], 'reject'),
                              tooltip: 'Отклонить',
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.red.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
