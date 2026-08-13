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

  DateTime _currentDate = DateTime.now();
  int get _month => _currentDate.month;
  int get _year => _currentDate.year;

  @override
  void initState() {
    super.initState();
    _loadData();
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

  // 🔥 СЛЕДУЮЩИЙ МЕСЯЦ
  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_year, _month + 1, 1);
    });
    _loadRating();
  }

  // 🔥 ПРЕДЫДУЩИЙ МЕСЯЦ
  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(_year, _month - 1, 1);
    });
    _loadRating();
  }

  String _getMonthName(int month) {
    const months = [
      'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
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

              const Divider(height: 1),

              // 🔥 ТАБЛИЦА РЕЙТИНГА (СО СВАЙПОМ)
              Expanded(
                child: _showClubSearch
                    ? ClubSearchList(
                        isDark: isDark,
                        onClubSelected: _selectClub,
                      )
                    : GestureDetector(
                        onHorizontalDragEnd: (details) {
                          if (details.primaryVelocity! < -100) {
                            _nextMonth();
                          } else if (details.primaryVelocity! > 100) {
                            _previousMonth();
                          }
                        },
                        child: _hasGames
                            ? SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8),
                                child: ClubRatingTable(players: _ratingPlayers),
                              )
                            : _buildNoGamesPlaceholder(isDark),
                      ),
              ),
            ],
          ),

          // 🔥 МЕСЯЦ И ГОД (ПОВЕРХ ВСЕГО)
          Positioned(
            top: 100,
            left: 16,
            child: Row(
              children: [
                // 🔥 МЕСЯЦ (КРУПНЫЙ, ЖИРНЫЙ)
                Text(
                  _getMonthName(_month),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 10),
                // 🔥 ГОД В КРУЖКЕ
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$_year',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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