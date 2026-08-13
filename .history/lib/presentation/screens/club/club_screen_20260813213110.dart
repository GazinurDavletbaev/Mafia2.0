// lib/presentation/screens/club/club_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/presentation/widgets/club/club_header.dart';
import 'package:mafia_help/presentation/widgets/club/club_rating_table.dart';
import 'package:mafia_help/presentation/widgets/club/club_search_list.dart';
import 'package:mdi_plus/mdi_plus.dart';
import '../../../services/club_service.dart';

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

  // 🔥 ДЛЯ ПЕРЕКЛЮЧЕНИЯ МЕСЯЦЕВ
  late PageController _pageController;
  int _currentPage = 0;
  final List<DateTime> _months = [];

  DateTime _currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _generateMonths();
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _generateMonths() {
    _months.clear();
    final now = DateTime.now();
    // 12 месяцев назад и 12 месяцев вперёд
    for (int i = -12; i <= 12; i++) {
      _months.add(DateTime(now.year, now.month + i, 1));
    }
    _months.sort((a, b) => a.compareTo(b));

    // Находим текущий месяц
    final current = DateTime(now.year, now.month, 1);
    final index = _months.indexOf(current);
    if (index != -1) {
      _currentPage = index;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pageController.jumpToPage(index);
      });
    }
  }

  void _selectClub(int clubId) {
    setState(() {
      _showClubSearch = false;
      _club = null;
      _ratingPlayers = [];
      _hasGames = false;
      _gamesCount = 0;
    });
    _loadData(clubId: clubId);
  }

  Future<void> _loadData({int? clubId}) async {
    setState(() => _isLoading = true);

    try {
      if (clubId != null) {
        final result = await ClubService.getClub(clubId);
        if (result['success']) {
          final clubData = result['club'] ?? result;
          _club = clubData;
          _hasClub = true;
          await _loadRating();
        } else {
          setState(() {
            _isLoading = false;
            _club = null;
            _hasClub = false;
          });
          return;
        }
      } else {
        final myClubsResult = await ClubService.getMyClub();
        final clubData = myClubsResult['club'];
        if (myClubsResult['success'] &&
            clubData != null &&
            clubData['id'] != null) {
          _club = clubData;
          _myClubId = clubData['id'];
          _hasClub = true;
          await _loadRating();
        } else {
          _hasClub = false;
          _club = null;
        }
      }
    } catch (e) {
      _hasClub = false;
      _club = null;
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loadRating({DateTime? date}) async {
    if (_club == null) return;

    final targetDate = date ?? _currentDate;
    final result = await ClubService.getClubRating(
      clubId: _club!['id'],
      month: targetDate.month,
      year: targetDate.year,
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

  void _onPageChanged(int index) {
    if (index < 0 || index >= _months.length) return;
    final date = _months[index];
    setState(() {
      _currentDate = date;
      _currentPage = index;
    });
    _loadRating(date: date);
  }

  String _getMonthName(int month) {
    const months = [
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Октябрь',
      'Ноябрь',
      'Декабрь'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              // 🔥 ХЕДЕР КЛУБА
              ClubHeader(
                club: _club,
                myClubId: _myClubId,
                gamesCount: _gamesCount,
                onRefresh: () => _loadData(clubId: _club?['id']),
              ),

              // 🔥 КРАСИВЫЙ ХЕДЕР С МЕСЯЦЕМ (как в Telegram/Instagram)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 🔥 СТРЕЛКА ВЛЕВО
                    GestureDetector(
                      onTap: () {
                        if (_currentPage > 0) {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage > 0
                              ? primaryColor.withOpacity(0.1)
                              : Colors.transparent,
                        ),
                        child: Icon(
                          Icons.chevron_left,
                          color: _currentPage > 0
                              ? primaryColor
                              : Colors.grey.shade400,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // 🔥 МЕСЯЦ (с анимацией)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        '${_getMonthName(_currentDate.month)} ${_currentDate.year}',
                        key: ValueKey(
                            '${_currentDate.month}${_currentDate.year}'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // 🔥 СТРЕЛКА ВПРАВО
                    GestureDetector(
                      onTap: () {
                        if (_currentPage < _months.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage < _months.length - 1
                              ? primaryColor.withOpacity(0.1)
                              : Colors.transparent,
                        ),
                        child: Icon(
                          Icons.chevron_right,
                          color: _currentPage < _months.length - 1
                              ? primaryColor
                              : Colors.grey.shade400,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 🔥 ИНДИКАТОР ТОЧЕК (как в Instagram)
              Container(
                height: 6,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _months.length > 7 ? 7 : _months.length,
                    (index) {
                      // Показываем точки вокруг текущей страницы
                      final int actualIndex;
                      if (_months.length <= 7) {
                        actualIndex = index;
                      } else {
                        final int start =
                            (_currentPage - 3).clamp(0, _months.length - 7);
                        actualIndex = start + index;
                      }
                      final bool isActive = actualIndex == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isActive ? 10 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isActive
                              ? primaryColor
                              : isDark
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const Divider(height: 1),

              // 🔥 ТАБЛИЦА РЕЙТИНГА (PageView для свайпа)
              Expanded(
                child: _showClubSearch
                    ? ClubSearchList(
                        isDark: isDark,
                        onClubSelected: _selectClub,
                      )
                    : PageView.builder(
                        controller: _pageController,
                        onPageChanged: _onPageChanged,
                        itemCount: _months.length,
                        itemBuilder: (context, index) {
                          final date = _months[index];
                          // Загружаем данные для этого месяца
                          // Используем текущие _ratingPlayers
                          return _hasGames
                              ? SingleChildScrollView(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child:
                                      ClubRatingTable(players: _ratingPlayers),
                                )
                              : _buildNoGamesPlaceholder(isDark);
                        },
                      ),
              ),
            ],
          ),

          // 🔥 КНОПКА "КЛУБЫ"
          if (!_showClubSearch)
            Positioned(
              bottom: 24,
              right: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: primaryColor,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() => _showClubSearch = true);
                        },
                        borderRadius: BorderRadius.circular(50),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Mdi.magnify,
                              color: isDark ? Colors.white : Colors.black87,
                              size: 20,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              'Клубы',
                              style: TextStyle(
                                fontSize: 8,
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 🔥 КНОПКА "СВОЙ"
          if (_showClubSearch)
            Positioned(
              bottom: 24,
              right: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: Colors.red,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() => _showClubSearch = false);
                        },
                        borderRadius: BorderRadius.circular(50),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.close,
                              color: isDark ? Colors.white : Colors.black87,
                              size: 20,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              'Свой',
                              style: TextStyle(
                                fontSize: 8,
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
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
