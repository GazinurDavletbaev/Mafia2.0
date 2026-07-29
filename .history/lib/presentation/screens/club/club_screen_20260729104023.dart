// lib/presentation/screens/club_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mafia_help/presentation/widgets/app_card.dart';
import 'package:mafia_help/presentation/widgets/app_text.dart';
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
  int? _myClubId;
  Map<String, dynamic>? _club;
  List<Map<String, dynamic>> _ratingPlayers = [];
  bool _hasGames = false;
  int _gamesCount = 0;
  int? _selectedClubId;

  DateTime _currentDate = DateTime.now();
  int get _month => _currentDate.month;
  int get _year => _currentDate.year;

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
        _loadAllClubs();
      }
    });
  }

  void _selectClub(int clubId) {
    setState(() {
      _showClubSearch = false;
    });
    _loadData(clubId: clubId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData({int? clubId}) async {
    setState(() => _isLoading = true);

    if (clubId != null) {
      print('📦 Загружаем выбранный клуб: $clubId');
      final result = await ClubService.getClub(clubId);
      print('📦 getClub result: $result');

      if (result['success']) {
        _club = result;
        _hasClub = true;
        _selectedClubId = clubId;
        await _loadRating();
        setState(() {});
      } else {
        print('❌ Ошибка загрузки клуба: ${result['error']}');
        setState(() => _isLoading = false);
        return;
      }
    } else {
      final myClubsResult = await ClubService.getMyClub();
      print('📦 myClubsResult: $myClubsResult');

      final clubData = myClubsResult['club'];
      if (myClubsResult['success'] &&
          clubData != null &&
          clubData['id'] != null) {
        print('✅ ЕСТЬ КЛУБ!');
        _club = clubData;
        _myClubId = clubData['id'];
        _hasClub = true;
        _selectedClubId = null;
        await _loadRating();
      } else {
        print('❌ НЕТ КЛУБА!');
        _hasClub = false;
        await _loadAllClubs();
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loadRating() async {
    if (_club == null) return;

    final result = await ClubService.getClubRating(
      clubId: _club!['id'],
      month: _month,
      year: _year,
    );

    print('📦 rating result: $result');

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _buildClubContent(theme),
    );
  }

  Widget _buildRatingTable() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_ratingPlayers.isEmpty) {
      return _buildNoGamesPlaceholder(isDark);
    }

    return Card(
      color: theme.cardColor,
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
                    0: const FixedColumnWidth(30),
                    1: FixedColumnWidth(nameWidth > 80 ? nameWidth : 80),
                    2: const FixedColumnWidth(50),
                    3: const FixedColumnWidth(50),
                    4: const FixedColumnWidth(50),
                    5: const FixedColumnWidth(50),
                    6: const FixedColumnWidth(50),
                  },
                  children: [
                    TableRow(
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
                    ..._ratingPlayers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final player = entry.value;
                      final total =
                          (player['points'] ?? 0) + (player['bonus'] ?? 0);
                      final isTop = index < 3;

                      return TableRow(
                        decoration: BoxDecoration(
                          color: null,
                        ),
                        children: [
                          _ratingCell(
                            '${index + 1}',
                            isTop: isTop,
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
                            color: Colors.amber.shade700,
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
                  ? theme.primaryColor
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

  Widget _buildClubContent(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    print('📦 _buildClubContent _club: $_club');
    print('📦 _buildClubContent _club: ${_club?['title']}');

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildClubHeader(),
              const SizedBox(height: 2),
              AppCard(
                isDark: isDark,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'РЕЙТИНГ КЛУБА',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildClubStats(),
                  ],
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
                foregroundColor: theme.primaryColor,
                side: BorderSide(color: theme.primaryColor, width: 0.8),
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
        Expanded(
          child: AppCard(
            isDark: isDark,
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
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
                  style: AppText.title(isDark: isDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '📍 ${_club?['city'] ?? 'Город не указан'}',
                  style: AppText.small(isDark: isDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              AppCard(
                isDark: isDark,
                padding: const EdgeInsets.all(12),
                margin: EdgeInsets.zero,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 21,
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
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _club?['president_name'] ?? 'Неизвестен',
                          style: AppText.subtitle(isDark: isDark),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Президент',
                          style: AppText.accent(isDark: isDark),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              AppCard(
                isDark: isDark,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.games,
                                    color: theme.primaryColor, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '$_gamesCount',
                                  style: AppText.button(isDark: isDark),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
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
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.people,
                                    color: theme.primaryColor, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${_club?['members_count'] ?? 0}',
                                  style: AppText.button(isDark: isDark),
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
                          style: AppText.small(isDark: isDark),
                        ),
                        const SizedBox(width: 40),
                        Text(
                          'Резиденты',
                          style: AppText.small(isDark: isDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: _buildJoinButton(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJoinButton() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final int? currentClubId = _club?['id'];
    final bool isMyClub = _myClubId == currentClubId;
    final bool hasPendingRequest = _club?['has_pending_request'] ?? false;

    if (_myClubId != null && !isMyClub) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: Colors.orange, size: 18),
            const SizedBox(width: 8),
            Text(
              'У вас есть клуб',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (isMyClub) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 18),
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
    }

    if (hasPendingRequest) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_top, color: Colors.orange, size: 18),
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
    }

    return ElevatedButton(
      onPressed: () => _joinClub(_club!['id']),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
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

  Future<void> _joinClub(int clubId) async {
    final result = await ClubService.joinClub(clubId);
    if (result['success']) {
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

    void filterClubs(String query) {
      final q = query.toLowerCase().trim();
      setState(() {
        if (q.isEmpty) {
          _filteredClubs = List.from(_allClubs);
        } else {
          _filteredClubs = _allClubs.where((club) {
            final title = club['title']?.toLowerCase() ?? '';
            final city = club['city']?.toLowerCase() ?? '';
            return title.contains(q) || city.contains(q);
          }).toList();
        }
      });
    }

    return Column(
      children: [
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
              prefixIcon: Icon(Icons.search, color: theme.primaryColor),
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
        Expanded(
          child: _allClubs.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _filteredClubs.isEmpty
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
                      itemCount: _filteredClubs.length,
                      itemBuilder: (context, index) {
                        final club = _filteredClubs[index];
                        final isOfficial = club['is_official'] == true;
                        final isMember = club['is_member'] == true;
                        final isPending = club['is_pending'] == true;

                        return GestureDetector(
                          onTap: () {
                            _selectClub(club['id']);
                          },
                          child: Card(
                            color: theme.cardColor,
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: isOfficial
                                  ? BorderSide(
                                      color: theme.primaryColor, width: 2)
                                  : BorderSide.none,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: isOfficial
                                        ? theme.primaryColor
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
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                club['title'] ?? 'Без названия',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: theme.textTheme
                                                          .bodyLarge?.color ??
                                                      Colors.white,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (isOfficial) ...[
                                              const SizedBox(width: 4),
                                              Icon(Icons.verified,
                                                  color: theme.primaryColor,
                                                  size: 16),
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
                                  if (isMember)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        '✅ Состою',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 11,
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
                                        '⏳ Заявка',
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
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
              icon:
                  Icon(Icons.chevron_left, size: 22, color: theme.primaryColor),
              onPressed: _previousMonth,
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
              icon: Icon(Icons.chevron_right,
                  size: 22, color: theme.primaryColor),
              onPressed: _nextMonth,
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
}
