// lib/presentation/screens/club_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../services/club_service.dart';
import '../../../services/update_service.dart';

class ClubScreen extends ConsumerStatefulWidget {
  const ClubScreen({super.key});

  @override
  ConsumerState<ClubScreen> createState() => _ClubScreenState();
}

class _ClubScreenState extends ConsumerState<ClubScreen> {
  bool _isLoading = true;
  bool _hasClub = false;

  // Данные клуба пользователя
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

    final myClubsResult = await ClubService.getMyClub();
    print('📦 myClubsResult: $myClubsResult');

    // ✅ Правильная проверка — клуб есть и у него есть id
    final clubData = myClubsResult['club'];
    if (myClubsResult['success'] &&
        clubData != null &&
        clubData['id'] != null) {
      print('✅ ЕСТЬ КЛУБ!');

      _club = clubData;
      _hasClub = true;

      await _loadRating();
      setState(() => _isLoading = false);
      return;
    }

    // 2. Нет клуба — загружаем список всех клубов
    print('❌ НЕТ КЛУБА!');
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

    print('📦 rating result: $result'); // 👈 ДОБАВЬ

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
  Widget _buildRatingTable() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_ratingPlayers.isEmpty) {
      return _buildNoGamesPlaceholder(isDark);
    }

    return Card(
      color: isDark ? Colors.grey.shade800 : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'РЕЙТИНГ КЛУБА',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                final fixedWidths = 30 + 40 + 50 + 50 + 50 + 50 + 50;
                final nameWidth = totalWidth - fixedWidths - 10;

                return Table(
                  border: TableBorder.all(
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                    width: 0.5,
                  ),
                  columnWidths: {
                    0: const FixedColumnWidth(30), // Место
                    1: FixedColumnWidth(
                        nameWidth > 80 ? nameWidth : 80), // Игрок
                    2: const FixedColumnWidth(50), // Игр
                    3: const FixedColumnWidth(50), // Побед
                    4: const FixedColumnWidth(50), // Очки
                    5: const FixedColumnWidth(50), // Бонус
                    6: const FixedColumnWidth(50), // Всего
                  },
                  children: [
                    // Заголовки
                    TableRow(
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade200,
                      ),
                      children: [
                        _ratingCell('№', isHeader: true),
                        _ratingCell('Игрок', isHeader: true),
                        _ratingCell('Игр',
                            isHeader: true, align: TextAlign.center),
                        _ratingCell('Побед',
                            isHeader: true, align: TextAlign.center),
                        _ratingCell('Очки',
                            isHeader: true, align: TextAlign.center),
                        _ratingCell('Бонус',
                            isHeader: true, align: TextAlign.center),
                        _ratingCell('Всего',
                            isHeader: true, align: TextAlign.center),
                      ],
                    ),
                    // Данные
                    ..._ratingPlayers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final player = entry.value;
                      final total =
                          (player['points'] ?? 0) + (player['bonus'] ?? 0);
                      final isTop = index < 3;

                      return TableRow(
                        decoration: BoxDecoration(
                          color: isTop
                              ? (isDark
                                  ? Colors.grey.shade700
                                  : Colors.orange.shade50)
                              : null,
                        ),
                        children: [
                          _ratingCell(
                            '${index + 1}',
                            isTop: isTop,
                            color: isTop ? Colors.orange : null,
                          ),
                          _ratingCell(
                            player['username'] ?? 'Игрок',
                            isTop: isTop,
                            fontWeight:
                                isTop ? FontWeight.bold : FontWeight.normal,
                          ),
                          _ratingCell(
                            '${player['games_played'] ?? 0}',
                            align: TextAlign.center,
                            isTop: isTop,
                          ),
                          _ratingCell(
                            '${player['wins'] ?? 0}',
                            align: TextAlign.center,
                            isTop: isTop,
                            color: Colors.yellow.shade700,
                          ),
                          _ratingCell(
                            '${player['points'] ?? 0}',
                            align: TextAlign.center,
                            isTop: isTop,
                          ),
                          _ratingCell(
                            '${player['bonus'] ?? 0}',
                            align: TextAlign.center,
                            isTop: isTop,
                            color: (player['bonus'] ?? 0) > 0
                                ? Colors.green
                                : (player['bonus'] ?? 0) < 0
                                    ? Colors.red
                                    : null,
                          ),
                          _ratingCell(
                            total.toString(),
                            align: TextAlign.center,
                            isTop: isTop,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _ratingCell(
    String text, {
    bool isHeader = false,
    bool isTop = false,
    TextAlign align = TextAlign.left,
    Color? color,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Text(
        text,
        style: TextStyle(
          color: color ??
              (isHeader
                  ? Colors.orange
                  : (isDark ? Colors.white : Colors.black87)),
          fontWeight: isHeader || fontWeight == FontWeight.bold
              ? FontWeight.bold
              : FontWeight.normal,
          fontSize: isHeader ? 12 : 13,
        ),
        textAlign: align,
      ),
    );
  }

  Widget _buildClubContent(ThemeData theme, bool isDark) {
    print('📦 _buildClubContent _club: $_club'); // 👈 ДОБАВЬ

    return Column(
      children: [
        Container(
          color: theme.scaffoldBackgroundColor,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildClubHeader(),
              const SizedBox(height: 16),
              _buildClubStats(),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _hasGames
              ? SingleChildScrollView(
                  // ← добавить скролл
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildRatingTable(),
                )
              : _buildNoGamesPlaceholder(isDark),
        ),
        // ✅ КНОПКА "ПОИСК КЛУБА"
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                context.push('/club-select');
              },
              icon: const Icon(Icons.search, size: 18),
              label: const Text('Найти другой клуб'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange, width: 0.8),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClubHeader() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ====== КОЛОНКА 1: Лого + Название + Город ======
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(14),
                  image: _club?['logo_url'] != null &&
                          _club!['logo_url'].isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(_club!['logo_url']),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _club?['logo_url'] == null || _club!['logo_url'].isEmpty
                    ? Image.asset(
                        'assets/mafia_logo.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      )
                    : null,
              ),
              const SizedBox(height: 8),
              Text(
                _club?['title'] ?? 'Клуб',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '📍 ${_club?['city'] ?? 'Город не указан'}',
                style: TextStyle(
                  color: isDark ? Colors.grey : Colors.grey.shade600,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // ====== КОЛОНКА 2: Аватар + Никнейм президента ======
        Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor:
                        isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    backgroundImage: _club?['president_avatar'] != null &&
                            _club!['president_avatar'].toString().isNotEmpty
                        ? NetworkImage(_club!['president_avatar'])
                        : null,
                    child: _club?['president_avatar'] == null ||
                            _club!['president_avatar'].toString().isEmpty
                        ? Text(
                            _club?['president_name']
                                    ?.substring(0, 1)
                                    .toUpperCase() ??
                                '?',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 4),
                  Column(
                    children: [
                      Text(
                        _club?['president_name'] ?? 'Неизвестен',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Президент Клуба',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
                              const SizedBox(height: 4),

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
              icon: const Icon(Icons.chevron_left, size: 22),
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
              icon: const Icon(Icons.chevron_right, size: 22),
              onPressed: _nextMonth,
              color: Colors.orange,
            ),
          ],
        ),
        Row(
          children: [
            // ✅ ИГРЫ — кликабельно
            GestureDetector(
              onTap: () {
                context.push(
                  '/club-games-list',
                  extra: {
                    'clubId': _club!['id'],
                    'clubTitle': _club!['title'] ?? 'Клуб',
                  },
                );
              },
              child: Row(
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
                ],
              ),
            ),
            const SizedBox(width: 12),
            // ✅ УЧАСТНИКИ — кликабельно
            GestureDetector(
              onTap: () {
                context.push(
                  '/club-members-list',
                  extra: {
                    'clubId': _club!['id'],
                    'clubTitle': _club!['title'] ?? 'Клуб',
                  },
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.people, color: Colors.orange, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${_club?['members_count'] ?? 0}', // ← members_count вместо judges_count
                    style: TextStyle(
                      color: isDark ? Colors.grey : Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
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
                    final isMember = club['is_member'] == true;
                    final isPending = club['is_pending'] == true;

                    return Card(
                      color: isDark ? Colors.grey.shade800 : Colors.white,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Основная информация
                          ListTile(
                            contentPadding: const EdgeInsets.all(12),
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
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
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
                                // ✅ Статус
                                if (isMember) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Вы состоите в клубе',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                                if (isPending) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Заявка отправлена',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // ✅ КНОПКИ (только если не состоит и нет заявки)
                          if (!isMember && !isPending)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                              child: Row(
                                children: [
                                  // Кнопка "Подать заявку"
                                  Expanded(
                                    child: SizedBox(
                                      height: 28,
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          final result =
                                              await ClubService.joinClub(
                                                  club['id']);
                                          if (result['success']) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content:
                                                    Text('Заявка отправлена!'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                            _loadAllClubs();
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(result['error'] ??
                                                    'Ошибка'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.green,
                                          side: const BorderSide(
                                              color: Colors.green, width: 0.8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(0, 28),
                                        ),
                                        child: const Text(
                                          'Подать заявку',
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Кнопка "Просмотр"
                                  Expanded(
                                    child: SizedBox(
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
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(0, 28),
                                        ),
                                        child: const Text(
                                          'Просмотр',
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Если состоит или заявка — только "Просмотр"
                          if (isMember || isPending)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                              child: Row(
                                children: [
                                  const Spacer(),
                                  SizedBox(
                                    height: 28,
                                    width: 80,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        context.push('/club-detail',
                                            extra: club['id']);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.orange,
                                        side: const BorderSide(
                                            color: Colors.orange, width: 0.8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 28),
                                      ),
                                      child: const Text(
                                        'Просмотр',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
