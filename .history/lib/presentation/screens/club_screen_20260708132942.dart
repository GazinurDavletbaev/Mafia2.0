// lib/presentation/screens/club_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/club_service.dart';
import '../../services/update_service.dart';

class ClubScreen extends ConsumerStatefulWidget {
  const ClubScreen({super.key});

  @override
  ConsumerState<ClubScreen> createState() => _ClubScreenState();
}

class _ClubScreenState extends ConsumerState<ClubScreen> {
  bool _isLoading = true;
  bool _hasClub = false;

  // Данные пользователя
  Map<String, dynamic>? _user;

  // Данные клуба
  Map<String, dynamic>? _club;
  List<Map<String, dynamic>> _ratingPlayers = [];
  bool _hasGames = false;
  int _gamesCount = 0;

  // Месяц для рейтинга
  DateTime _currentDate = DateTime.now();
  int get _month => _currentDate.month;
  int get _year => _currentDate.year;

  // Поиск клубов
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _allClubs = [];
  List<Map<String, dynamic>> _filteredClubs = [];

  @override
  void initState() {
    super.initState();
    _loadData();
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

  // ============================================================
  // ЗАГРУЗКА ДАННЫХ
  // ============================================================
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // 1. Получаем клубы пользователя
    final myClubsResult = await ClubService.getMyClubs();

    if (myClubsResult['success'] && myClubsResult['clubs'] != null) {
      final clubs = myClubsResult['clubs'] as List? ?? [];
      if (clubs.isNotEmpty) {
        _club = clubs[0];
        _hasClub = true;
        await _loadRating();
        setState(() => _isLoading = false);
        return;
      }
    }

    // 2. Нет клуба — загружаем список всех клубов
    _hasClub = false;
    await _loadAllClubs();
    setState(() => _isLoading = false);
  }

  Future<void> _loadRating() async {
    if (_club == null) return;

    final result = await ClubService.getClubRating(
      clubId: _club!['id'],
      month: _month,
      year: _year,
    );

    if (result['success']) {
      setState(() {
        _hasGames = result['has_games'] ?? false;
        _gamesCount = result['games_played'] ?? 0;
        _ratingPlayers =
            (result['players'] as List? ?? []).cast<Map<String, dynamic>>();
      });
    }
  }

  Future<void> _loadAllClubs() async {
    final result = await ClubService.getAllClubs();
    if (result['success']) {
      setState(() {
        _allClubs =
            (result['clubs'] as List? ?? []).cast<Map<String, dynamic>>();
        _filteredClubs = List.from(_allClubs);
      });
    }
  }

  // ============================================================
  // НАВИГАЦИЯ ПО МЕСЯЦАМ
  // ============================================================
  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(_year, _month - 1, 1);
    });
    if (_hasClub) _loadRating();
  }

  void _nextMonth() {
    final nextDate = DateTime(_year, _month + 1, 1);
    if (nextDate.isBefore(DateTime.now()) ||
        (nextDate.month == DateTime.now().month &&
            nextDate.year == DateTime.now().year)) {
      setState(() {
        _currentDate = nextDate;
      });
      if (_hasClub) _loadRating();
    }
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _hasClub
          ? _buildClubContent(theme, isDark)
          : _buildClubList(theme, isDark),
    );
  }

  // ============================================================
  // 1. ЕСТЬ КЛУБ
  // ============================================================
  Widget _buildClubContent(ThemeData theme, bool isDark) {
    return Column(
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
          child: _hasGames
              ? _buildRatingTable(isDark)
              : _buildNoGamesPlaceholder(isDark),
        ),
      ],
    );
  }

  Widget _buildClubHeader() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
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
              Row(
                children: [
                  Text(
                    _club?['title'] ?? 'Клуб',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (_club?['is_official'] == true) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, color: Colors.orange, size: 18),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                _club?['city'] ?? 'Город не указан',
                style: TextStyle(
                  color: isDark ? Colors.grey : Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.person, size: 14, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    'Президент: ${_club?['president_name'] ?? 'Неизвестен'}',
                    style: TextStyle(
                      color: isDark ? Colors.grey : Colors.grey.shade600,
                      fontSize: 13,
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
    final monthNames = [
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Окторябрь',
      'Ноябрь',
      'Декабрь'
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.chevron_left),
              onPressed: _previousMonth,
              color: Colors.orange,
            ),
            const SizedBox(width: 4),
            Text(
              '${monthNames[_month - 1]} $_year',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey : Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.chevron_right),
              onPressed: _nextMonth,
              color: Colors.orange,
            ),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.games, color: Colors.orange, size: 16),
            const SizedBox(width: 4),
            Text(
              'Игр: $_gamesCount',
              style: TextStyle(
                color: isDark ? Colors.grey : Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.people, color: Colors.orange, size: 16),
            const SizedBox(width: 4),
            Text(
              'Участников: ${_club?['judges_count'] ?? 0}',
              style: TextStyle(
                color: isDark ? Colors.grey : Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingTable(bool isDark) {
    if (_ratingPlayers.isEmpty) {
      return _buildNoGamesPlaceholder(isDark);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _ratingPlayers.length,
      itemBuilder: (context, index) {
        final player = _ratingPlayers[index];
        final total = (player['points'] ?? 0) + (player['bonus'] ?? 0);
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

  Widget _buildNoGamesPlaceholder(bool isDark) {
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

  // ============================================================
  // 2. НЕТ КЛУБА — СПИСОК КЛУБОВ
  // ============================================================
  Widget _buildClubList(ThemeData theme, bool isDark) {
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
                _filteredClubs = _allClubs.where((club) {
                  final title = club['title']?.toLowerCase() ?? '';
                  final city = club['city']?.toLowerCase() ?? '';
                  final query = value.toLowerCase();
                  return title.contains(query) || city.contains(query);
                }).toList();
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
                          _filteredClubs = List.from(_allClubs);
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),
        // Список клубов
        Expanded(
          child: _filteredClubs.isEmpty
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
                  itemCount: _filteredClubs.length,
                  itemBuilder: (context, index) {
                    final club = _filteredClubs[index];
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
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                club['title'] ?? 'Без названия',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (club['is_official'] == true) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified,
                                  color: Colors.orange, size: 16),
                            ],
                          ],
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
                              '👤 Президент: ${club['president_name'] ?? 'Неизвестен'}',
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ✅ Кнопка "Подать заявку"
                            OutlinedButton(
                              onPressed: () async {
                                final result =
                                    await ClubService.joinClub(club['id']);
                                if (result['success']) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Заявка отправлена!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text(result['error'] ?? 'Ошибка'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.green,
                                side: const BorderSide(color: Colors.green),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Подать заявку'),
                            ),
                            const SizedBox(width: 8),
                            // Кнопка "Просмотр"
                            OutlinedButton(
                              onPressed: () {
                                context.push('/club-detail', extra: club['id']);
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
                          ],
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
