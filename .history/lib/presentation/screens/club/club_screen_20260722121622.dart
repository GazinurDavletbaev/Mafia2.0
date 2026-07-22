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
  bool _showClubSearch = false;
  
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
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildClubHeader(),
              const SizedBox(height: 2),

              // ====== РЕЙТИНГ КЛУБА + Статистика ======
              Card(
                color: isDark ? Colors.grey.shade800 : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'РЕЙТИНГ КЛУБА',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildClubStats(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _showClubSearch
              ? _buildClubSearchList(isDark)
              : _hasGames
                  ? SingleChildScrollView(
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
                setState(() {
                  _showClubSearch = true;
                });
              },
              icon: const Icon(Icons.search, size: 18),
              label: const Text('Найти клуб'),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ====== КОЛОНКА 1: Лого + Название + Город ======
        Expanded(
          child: Card(
            color: isDark ? Colors.grey.shade800 : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color:
                          isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(14),
                      image: _club?['logo_url'] != null &&
                              _club!['logo_url'].isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(_club!['logo_url']),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child:
                        _club?['logo_url'] == null || _club!['logo_url'].isEmpty
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
          ),
        ),
        const SizedBox(width: 12),

        // ====== КОЛОНКА 2: Аватар + Никнейм + Кнопки ======
        // ====== КОЛОНКА 2: Аватар + Никнейм + Кнопки ======
        Expanded(
          child: Column(
            children: [
              // Карточка 1: Аватар + имя президента
              Card(
                color: isDark ? Colors.grey.shade800 : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 21,
                        backgroundColor: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
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
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          const SizedBox(height: 2),
                          Text(
                            'Президент',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Карточка 2: Игры + Участники
              Card(
                color: isDark ? Colors.grey.shade800 : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ✅ ИГРЫ
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
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.games,
                                      color: Colors.orange, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$_gamesCount',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // ✅ УЧАСТНИКИ
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
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.people,
                                      color: Colors.orange, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_club?['members_count'] ?? 0}',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Игры',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.grey.shade500
                                  : Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(width: 40),
                          Text(
                            'Резиденты',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.grey.shade500
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // ====== КНОПКА "ПОДАТЬ ЗАЯВКУ" ======
                      SizedBox(
                        width: double.infinity,
                        child: _buildJoinButton(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJoinButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isMember = _club?['is_member'] ?? false;
    final hasPendingRequest = _club?['has_pending_request'] ?? false;

    if (isMember) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 18),
            const SizedBox(width: 8),
            Text(
              '✅ Ваш клуб',
              style: TextStyle(
                color: Colors.green,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else if (hasPendingRequest) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_top, color: Colors.orange, size: 18),
            const SizedBox(width: 8),
            Text(
              '⏳ Заявка отправлена',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: () => _joinClub(_club!['id']),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          minimumSize: const Size(double.infinity, 0),
        ),
        child: const Text(
          '📩 Подать заявку',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
  }

  Future<void> _joinClub(int clubId) async {
    final result = await ClubService.joinClub(clubId);
    if (result['success']) {
      // ✅ Обновляем данные клуба
      await _loadClubData(clubId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заявка отправлена!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Ошибка'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadClubData(int clubId) async {
    setState(() => _isLoading = true);

    final result = await ClubService.getClub(clubId);
    if (result['success']) {
      setState(() {
        _club = result['club'];
        _hasClub = true;
      });
      await _loadRating();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Ошибка загрузки клуба'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  Widget _buildClubSearchList(bool isDark) {
    final theme = Theme.of(context);
    final searchController = TextEditingController();
    String searchQuery = '';
    List<Map<String, dynamic>> allClubs = [];
    List<Map<String, dynamic>> filteredClubs = [];
    bool isLoading = true;

    // Загружаем клубы при первом открытии
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (allClubs.isEmpty) {
        final result = await ClubService.getAllClubs();
        setState(() {
          final clubsData = result['clubs'] as List? ?? [];
          allClubs = clubsData.cast<Map<String, dynamic>>();
          filteredClubs = List.from(allClubs);
          isLoading = false;
        });
      }
    });

    void filterClubs(String query) {
      final q = query.toLowerCase().trim();
      setState(() {
        if (q.isEmpty) {
          filteredClubs = List.from(allClubs);
        } else {
          filteredClubs = allClubs.where((club) {
            final title = club['title']?.toLowerCase() ?? '';
            final city = club['city']?.toLowerCase() ?? '';
            return title.contains(q) || city.contains(q);
          }).toList();
        }
      });
    }

    return Column(
      children: [
        // Поле поиска
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: searchController,
            onChanged: filterClubs,
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
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        searchController.clear();
                        filterClubs('');
                      },
                    )
                  : null,
            ),
          ),
        ),
        // Список клубов
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredClubs.isEmpty
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
                            searchController.text.isEmpty
                                ? 'Клубы не найдены'
                                : 'Ничего не найдено',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: filteredClubs.length,
                      itemBuilder: (context, index) {
                        final club = filteredClubs[index];
                        final isOfficial = club['is_official'] == true;
                        final isMember = club['is_member'] == true;
                        final isPending = club['is_pending'] == true;

                        return Card(
                          color: isDark ? Colors.grey.shade800 : Colors.white,
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: isOfficial
                                ? const BorderSide(
                                    color: Colors.orange, width: 2)
                                : BorderSide.none,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: CircleAvatar(
                              backgroundColor: isOfficial
                                  ? Colors.orange
                                  : Colors.grey.shade300,
                              child: Text(
                                club['title']?.substring(0, 1).toUpperCase() ??
                                    '?',
                                style: TextStyle(
                                  color: isOfficial
                                      ? Colors.white
                                      : Colors.black54,
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
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: theme.textTheme.bodyLarge?.color ??
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
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                            trailing: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Кнопка "Просмотр"
                                SizedBox(
                                  width: 80,
                                  height: 28,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      _selectClub(club['id']);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.orange,
                                      side: const BorderSide(
                                          color: Colors.orange, width: 0.8),
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
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
                                // Статус или кнопка "Подать заявку"
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
                                      onPressed: () =>
                                          _joinClubFromSearch(club['id']),
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
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  void _selectClub(int clubId) {
    _loadClubData(clubId);
    setState(() {
      _showClubSearch = false;
    });
  }

  Future<void> _joinClubFromSearch(int clubId) async {
    final result = await ClubService.joinClub(clubId);
    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заявка отправлена!'),
          backgroundColor: Colors.green,
        ),
      );
      // Обновляем список клубов (перезагружаем)
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Ошибка'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
