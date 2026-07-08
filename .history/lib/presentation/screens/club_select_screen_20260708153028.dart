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
      final clubsData = result['clubs'] as List? ?? [];
      _allClubs = clubsData.cast<Map<String, dynamic>>();
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
                  fillColor:
                      isDark ? Colors.grey.shade800 : Colors.grey.shade200,
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
                          color: isDark
                              ? Colors.grey.shade600
                              : Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'Клубы не найдены'
                              : 'Ничего не найдено',
                          style: TextStyle(
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
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
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Левая часть: аватар + информация
                              CircleAvatar(
                                backgroundColor: isOfficial
                                    ? Colors.orange
                                    : Colors.grey.shade300,
                                child: Text(
                                  club['title']
                                          ?.substring(0, 1)
                                          .toUpperCase() ??
                                      '?',
                                  style: TextStyle(
                                    color: isOfficial
                                        ? Colors.white
                                        : Colors.black54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Информация о клубе
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            club['title'] ?? 'Без названия',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: theme.textTheme.bodyLarge
                                                      ?.color ??
                                                  Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isOfficial) ...[
                                          const SizedBox(width: 4),
                                          const Icon(Icons.verified,
                                              color: Colors.orange, size: 16),
                                        ],
                                      ],
                                    ),
                                    if (club['city'] != null &&
                                        club['city'].isNotEmpty)
                                      Text(
                                        '📍 ${club['city']}',
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.grey.shade400
                                              : Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    Text(
                                      '👤 ${club['president_name'] ?? 'Неизвестен'}',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '👥 ${club['judges_count'] ?? 0} участников',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Правая часть: кнопки колонкой
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Кнопка "Просмотр"
                                  SizedBox(
                                    width: 80,
                                    height: 28,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        context.push('/club-detail',
                                            extra: club['id']);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.orange,
                                        side: const BorderSide(
                                            color: Colors.orange, width: 0.8),
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        minimumSize: const Size(0, 28),
                                      ),
                                      child: const Text(
                                        'Просмотр',
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Кнопка "Подать заявку" / статус
                                  if (isMember)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'Состою',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                  else if (isPending)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'Заявка подана',
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                  else
                                    SizedBox(
                                      width: 80,
                                      height: 28,
                                      child: ElevatedButton(
                                        onPressed: () => _joinClub(club['id']),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          foregroundColor: Colors.black,
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          minimumSize: const Size(0, 28),
                                        ),
                                        child: const Text(
                                          'Подать заявку',
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ));
  }
}
