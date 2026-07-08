// lib/presentation/screens/club_select_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/club_service.dart';

class ClubSelectScreen extends ConsumerStatefulWidget {
  const ClubSelectScreen({super.key});

  @override
  ConsumerState<ClubSelectScreen> createState() => _ClubSelectScreenState();
}

class _ClubSelectScreenState extends ConsumerState<ClubSelectScreen> {
  List<Map<String, dynamic>> _allClubs = [];
  List<Map<String, dynamic>> _filteredClubs = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadClubs();
    _searchController.addListener(_filterClubs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClubs() async {
    setState(() => _isLoading = true);
    final result = await ClubService.getAllClubs();
    setState(() {
      _allClubs = result['success'] ? (result['clubs'] as List? ?? []) : [];
      _filteredClubs = List.from(_allClubs);
      _isLoading = false;
    });
  }

  void _filterClubs() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredClubs = List.from(_allClubs);
      } else {
        _filteredClubs = _allClubs.where((club) {
          final title = club['title']?.toLowerCase() ?? '';
          final city = club['city']?.toLowerCase() ?? '';
          return title.contains(query) || city.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _joinClub(int clubId) async {
    final result = await ClubService.joinClub(clubId);
    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заявка отправлена!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadClubs();
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
        title: const Text('Поиск клубов'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color ?? Colors.white,
              ),
              decoration: InputDecoration(
                hintText: 'Поиск по названию или городу...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                ),
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.orange),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _filterClubs();
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredClubs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchController.text.isEmpty
                            ? 'Клубы не найдены'
                            : 'Ничего не найдено',
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                            _filterClubs();
                          },
                          child: const Text(
                            'Сбросить поиск',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredClubs.length,
                  itemBuilder: (context, index) {
                    final club = _filteredClubs[index];
                    final isOfficial = club['is_official'] == true;
                    final isMember = club['is_member'] == true;
                    final isPending = club['is_pending'] == true;

                    return Card(
                      color: isDark ? Colors.grey.shade800 : Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isOfficial
                            ? const BorderSide(color: Colors.orange, width: 2)
                            : BorderSide.none,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: isOfficial ? Colors.orange : Colors.grey.shade300,
                          child: Text(
                            club['title']?.substring(0, 1).toUpperCase() ?? '?',
                            style: TextStyle(
                              color: isOfficial ? Colors.white : Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                club['title'] ?? 'Без названия',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isOfficial) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                color: Colors.orange,
                                size: 18,
                              ),
                            ],
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (club['city'] != null && club['city'].isNotEmpty)
                              Text(
                                '📍 ${club['city']}',
                                style: TextStyle(
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            Text(
                              '👤 Президент: ${club['president_name'] ?? 'Неизвестен'}',
                              style: TextStyle(
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '👥 ${club['judges_count'] ?? 0} участников',
                              style: TextStyle(
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        trailing: isMember
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Состою',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            : isPending
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Заявка подана',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: () => _joinClub(club['id']),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Подать заявку',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                      ),
                    );
                  },
                ),
    );
  }
}