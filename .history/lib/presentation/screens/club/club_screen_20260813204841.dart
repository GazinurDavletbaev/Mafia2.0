// lib/presentation/screens/club/club_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/presentation/widgets/app_card.dart';
import 'package:mafia_help/presentation/widgets/club/club_header.dart';
import 'package:mafia_help/presentation/widgets/club/club_rating_table.dart';
import 'package:mafia_help/presentation/widgets/club/club_search_list.dart';
import 'package:mafia_help/presentation/widgets/club/club_stats.dart';
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

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
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
                // 🔥 ВСЁ В ОДНУ СТРОЧКУ
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      // 🔥 НАЙТИ КЛУБ (иконка + текст)
                      GestureDetector(
                        onTap: () {
                          setState(() => _showClubSearch = !_showClubSearch);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _showClubSearch
                                ? theme.primaryColor.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _showClubSearch
                                  ? theme.primaryColor
                                  : Colors.grey.shade400,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                size: 18,
                                color: _showClubSearch
                                    ? theme.primaryColor
                                    : Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Клубы',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _showClubSearch
                                      ? theme.primaryColor
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // 🔥 ПОДАТЬ ЗАЯВКУ (если есть клуб и это не мой клуб)
                      if (_club != null && _myClubId != _club!['id'])
                        GestureDetector(
                          onTap: () async {
                            final result =
                                await ClubService.joinClub(_club!['id']);
                            if (result['success']) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('✅ Заявка отправлена!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              _loadData(clubId: _club!['id']);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result['error'] ?? 'Ошибка'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: theme.primaryColor,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person_add,
                                  size: 18,
                                  color: theme.primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Заявка',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const Spacer(),

                      // 🔥 МЕСЯЦ + СТРЕЛКИ
                      Row(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              Icons.chevron_left,
                              size: 24,
                              color: theme.primaryColor,
                            ),
                            onPressed: _previousMonth,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_getMonthName(_month)} $_year',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              Icons.chevron_right,
                              size: 24,
                              color: theme.primaryColor,
                            ),
                            onPressed: _nextMonth,
                          ),
                        ],
                      ),
                    ],
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
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Янв',
      'Фев',
      'Мар',
      'Апр',
      'Май',
      'Июн',
      'Июл',
      'Авг',
      'Сен',
      'Окт',
      'Ноя',
      'Дек'
    ];
    return months[month - 1];
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
