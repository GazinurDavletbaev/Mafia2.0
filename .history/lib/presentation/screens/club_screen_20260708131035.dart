// lib/presentation/screens/club_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/update_service.dart';

class ClubScreen extends ConsumerStatefulWidget {
  const ClubScreen({super.key});

  @override
  ConsumerState<ClubScreen> createState() => _ClubScreenState();
}

class _ClubScreenState extends ConsumerState<ClubScreen> {
  bool _hasClub = false; // ← временно false для теста списка клубов
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Заглушка — список клубов
  final List<Map<String, dynamic>> _allClubs = [
    {
      'id': 1,
      'title': 'Mafia Legends',
      'city': 'Казань',
      'president': 'googlead',
      'members': 15
    },
    {
      'id': 2,
      'title': 'Black Mafia',
      'city': 'Москва',
      'president': 'ivanov',
      'members': 23
    },
    {
      'id': 3,
      'title': 'Red Town',
      'city': 'Санкт-Петербург',
      'president': 'petrov',
      'members': 8
    },
    {
      'id': 4,
      'title': 'Mafia Kings',
      'city': 'Новосибирск',
      'president': 'sidorov',
      'members': 31
    },
    {
      'id': 5,
      'title': 'Городская Мафия',
      'city': 'Екатеринбург',
      'president': 'smirnov',
      'members': 12
    },
    {
      'id': 6,
      'title': 'The Don',
      'city': 'Казань',
      'president': 'kozloff',
      'members': 19
    },
    {
      'id': 7,
      'title': 'Mafia Empire',
      'city': 'Москва',
      'president': 'morozov',
      'members': 27
    },
  ];

  List<Map<String, dynamic>> get _filteredClubs {
    if (_searchQuery.isEmpty) return _allClubs;
    return _allClubs.where((club) {
      final title = club['title']?.toLowerCase() ?? '';
      final city = club['city']?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || city.contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        UpdateService.checkForUpdate(context);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _hasClub
          ? _buildClubContent(theme, isDark)
          : _buildClubList(theme, isDark),
    );
  }

  // ============================================================
  // 1. ПОЛЬЗОВАТЕЛЬ СОСТОИТ В КЛУБЕ
  // ============================================================
  Widget _buildClubContent(ThemeData theme, bool isDark) {
    final players = _generatePlayers(40);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            color: theme.scaffoldBackgroundColor,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildClubHeader(),
                const SizedBox(height: 20),
                _buildClubStats(),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _buildRatingTable(players, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildClubHeader() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        // ✅ ЛОГОТИП КЛУБА — ЗАГЛУШКА
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Image.asset(
            'assets/mafia_logo.png',
            width: 60,
            height: 60,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MAFIA HELP',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Когда я читаю книгу, книга получает знания :) !',
                style: TextStyle(
                  color: isDark ? Colors.grey : Colors.grey.shade600,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color:
                          isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(
                      'assets/mafia_logo.png',
                      width: 18,
                      height: 18,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Google',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange, width: 0.5),
                    ),
                    child: const Text(
                      'Президент',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClubStats() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        _buildStatCard(
          icon: Icons.emoji_events,
          value: '1',
          label: 'место в рейтинге',
          color: Colors.orange,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.people,
          value: '40',
          label: 'резидентов клуба',
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: isDark ? Colors.grey : Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingTable(List<Map<String, dynamic>> players, bool isDark) {
    if (players.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_score,
              size: 48,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'В этом месяце игр не проводилось',
              style: TextStyle(
                color: isDark ? Colors.grey : Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        final total = player['points'] ?? 0;
        final isTop = index < 3;

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: isTop
                ? Border.all(
                    color: index == 0
                        ? Colors.yellow
                        : index == 1
                            ? Colors.grey.shade400
                            : index == 2
                                ? Colors.brown.shade300
                                : Colors.transparent,
                    width: 1.5,
                  )
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isTop ? Colors.orange : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isTop
                          ? Colors.white
                          : (isDark ? Colors.grey : Colors.grey.shade600),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  player['username'] ?? 'Игрок',
                  style: TextStyle(
                    fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.emoji_events,
                      color: Colors.yellow, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${player['wins'] ?? 0}',
                    style: TextStyle(
                      color: isDark ? Colors.grey : Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    total.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _generatePlayers(int count) {
    final names = [
      'Алексей',
      'Дмитрий',
      'Сергей',
      'Иван',
      'Петр',
      'Михаил',
      'Андрей',
      'Николай',
      'Олег',
      'Владимир',
      'Артем',
      'Максим',
    ];

    final players = <Map<String, dynamic>>[];
    for (int i = 0; i < count && i < names.length; i++) {
      players.add({
        'username': names[i % names.length],
        'points': 50 - i * 1 + (i % 5),
        'wins': 10 - i ~/ 4,
      });
    }
    return players;
  }

  // ============================================================
  // 2. ПОЛЬЗОВАТЕЛЬ НЕ СОСТОИТ В КЛУБЕ — СПИСОК КЛУБОВ
  // ============================================================
  Widget _buildClubList(ThemeData theme, bool isDark) {
    final filteredClubs = _filteredClubs;

    return Column(
      children: [
        // Поиск
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color ?? Colors.white,
            ),
            decoration: InputDecoration(
              hintText: 'Поиск клуба...',
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
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),

        // Список клубов
        Expanded(
          child: filteredClubs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: isDark
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Клубы не найдены',
                        style: TextStyle(
                          color: isDark ? Colors.grey : Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredClubs.length,
                  itemBuilder: (context, index) {
                    final club = filteredClubs[index];
                    return Card(
                      color: isDark ? Colors.grey.shade800 : Colors.white,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange.shade200,
                          child: Image.asset(
                            'assets/mafia_logo.png',
                            width: 28,
                            height: 28,
                            fit: BoxFit.contain,
                          ),
                        ),
                        title: Text(
                          club['title'] ?? 'Без названия',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📍 ${club['city'] ?? 'Город не указан'}',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '👤 Президент: ${club['president'] ?? 'Неизвестен'}',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '👥 ${club['members'] ?? 0} участников',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: OutlinedButton(
                          onPressed: () {
                            // TODO: переход на просмотр клуба
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Просмотр клуба (в разработке)'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            side: const BorderSide(color: Colors.orange),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Просмотр'),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
