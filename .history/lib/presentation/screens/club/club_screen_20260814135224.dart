// lib/presentation/screens/club/club_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/presentation/widgets/club/club_game_table.dart';
import 'package:mafia_help/presentation/widgets/club/club_header.dart';
import 'package:mafia_help/presentation/widgets/club/club_rating_table.dart';
import 'package:mafia_help/presentation/widgets/club/club_search_list.dart';
import 'package:mafia_help/presentation/widgets/club/club_members_table.dart';
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
  int _currentTab = 0;

  List<Map<String, dynamic>> _games = [];
  List<Map<String, dynamic>> _members = [];
  bool _isLoadingGames = false;
  bool _isLoadingMembers = false;

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
      _games = [];
      _members = [];
      _currentTab = 0;
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
          await _loadGames();
          await _loadMembers();
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
          await _loadGames();
          await _loadMembers();
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

  Future<void> _loadGames() async {
    if (_club == null) return;
    setState(() => _isLoadingGames = true);

    final result = await ClubService.getClubGames(_club!['id']);
    if (result['success']) {
      List data = [];
      if (result['data'] != null) {
        data = result['data'] as List;
      } else if (result['clubs'] != null) {
        data = result['clubs'] as List;
      }
      setState(() {
        _games = data.cast<Map<String, dynamic>>();
        _isLoadingGames = false;
      });
    } else {
      setState(() => _isLoadingGames = false);
    }
  }

  Future<void> _loadMembers() async {
    if (_club == null) return;
    setState(() => _isLoadingMembers = true);

    final result = await ClubService.getClubMembers(_club!['id']);
    if (result['success']) {
      setState(() {
        _members =
            (result['members'] as List? ?? []).cast<Map<String, dynamic>>();
        _isLoadingMembers = false;
      });
    } else {
      setState(() => _isLoadingMembers = false);
    }
  }

  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_year, _month + 1, 1);
    });
    _loadRating();
  }

  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(_year, _month - 1, 1);
    });
    _loadRating();
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

  Widget _buildContent() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    switch (_currentTab) {
      case 0:
        return _hasGames
            ? SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ClubRatingTable(players: _ratingPlayers),
              )
            : _buildNoGamesPlaceholder(isDark);
      case 1:
        return _isLoadingGames
            ? const Center(child: CircularProgressIndicator())
            : ClubGamesTable(games: _games, isDark: isDark);
      case 2:
        return _isLoadingMembers
            ? const Center(child: CircularProgressIndicator())
            : ClubMembersTable(
                members: _members,
                isDark: isDark,
                clubId: _club!['id'],
              );
      default:
        return const SizedBox.shrink();
    }
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
              ClubHeader(
                club: _club,
                myClubId: _myClubId,
                gamesCount: _gamesCount,
                onRefresh: () => _loadData(clubId: _club?['id']),
                onGamesTap: () {
                  setState(() {
                    _currentTab = 1;
                  });
                },
                onMembersTap: () {
                  setState(() {
                    _currentTab = 2;
                  });
                },
                onMyClubTap: () {
                  setState(() {
                    _currentTab = 0;
                  });
                },
              ),
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
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: _buildContent(),
          ),
        ),
),
            ],
          ),

          // 🔥 ПЛАВАЮЩИЙ ВИДЖЕТ С МЕСЯЦЕМ И ГОДОМ
          Positioned(
            top: 210,
            left: 5,
            child: Stack(
              clipBehavior: Clip.none, // 🔥 РАЗРЕШАЕТ ВЫХОДИТЬ ЗА ГРАНИЦЫ
              children: [
                // 🔥 ОСНОВНОЙ КОНТЕЙНЕР С МЕСЯЦЕМ
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade900 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _getMonthName(_month),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                // 🔥 КРУГЛЫЙ БЕЙДЖ С ГОДОМ (ВЫХОДИТ ЗА РАМКИ)
                Positioned(
                  top: -8,
                  right: -16,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? Colors.grey.shade900 : Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _year.toString().substring(2),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
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
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: Colors.white,
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
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              'Клубы',
                              style: const TextStyle(
                                fontSize: 8,
                                color: Colors.white70,
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
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: Colors.white,
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
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              'Свой',
                              style: const TextStyle(
                                fontSize: 8,
                                color: Colors.white70,
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
