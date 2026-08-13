// lib/presentation/screens/club/club_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/presentation/widgets/app_card.dart';
import 'package:mafia_help/presentation/widgets/club/club_header.dart';
import 'package:mafia_help/presentation/widgets/club/club_rating_table.dart';
import 'package:mafia_help/presentation/widgets/club/club_search_list.dart';
import 'package:mafia_help/presentation/widgets/club/club_stats.dart';
import 'package:mdi_plus/mdi_plus.dart';
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
        print('🔥 getClub result: $result');

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
        print('🔥 getMyClub result: $myClubsResult');

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
      print('❌ _loadData exception: $e');
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

  void _previousMonth() {
    setState(() => _currentDate = DateTime(_year, _month - 1, 1));
    _loadRating();
  }

  void _nextMonth() {
    final nextDate = DateTime(_year, _month + 1, 1);
    if (nextDate.isBefore(DateTime.now()) ||
        (nextDate.month == DateTime.now().month &&
            nextDate.year == DateTime.now().year)) {
      setState(() => _currentDate = nextDate);
      _loadRating();
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
          // 🔥 ОСНОВНОЙ КОНТЕНТ
          Column(
            children: [
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClubHeader(
                      club: _club,
                      myClubId: _myClubId,
                      gamesCount: _gamesCount,
                      onRefresh: () => _loadData(clubId: _club?['id']),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: AppCard(
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
                            ClubStats(
                              month: _month,
                              year: _year,
                              onPrevious: _previousMonth,
                              onNext: _nextMonth,
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
                    ? ClubSearchList(
                        isDark: isDark,
                        onClubSelected: _selectClub,
                      )
                    : _hasGames
                        ? SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: ClubRatingTable(players: _ratingPlayers),
                          )
                        : _buildNoGamesPlaceholder(isDark),
              ),
            ],
          ),
          // 🔥 ПЛАВАЮЩАЯ КНОПКА "НАЙТИ КЛУБ"
          // 🔥 ПЛАВАЮЩАЯ КНОПКА "НАЙТИ КЛУБ" С НАДПИСЬЮ ВНУТРИ
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
                              Mdi.home,
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
          // 🔥 КНОПКА "ЗАКРЫТЬ" С НАДПИСЬЮ "Свой"
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
