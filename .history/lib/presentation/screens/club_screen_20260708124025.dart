// lib/presentation/screens/club_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/club_service.dart';

class ClubScreen extends ConsumerStatefulWidget {
  const ClubScreen({super.key});

  @override
  ConsumerState<ClubScreen> createState() => _ClubScreenState();
}

class _ClubScreenState extends ConsumerState<ClubScreen> {
  Map<String, dynamic>? _club;
  Map<String, dynamic>? _rating;
  bool _isLoading = true;
  
  // Текущий месяц
  DateTime _currentDate = DateTime.now();
  int get _month => _currentDate.month;
  int get _year => _currentDate.year;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final clubResult = await ClubService.getCurrentClub();
    if (clubResult['success'] && clubResult['club'] != null) {
      _club = clubResult['club'];
      await _loadRating();
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
      setState(() => _rating = result);
    }
  }

  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(_year, _month - 1, 1);
    });
    _loadRating();
  }

  void _nextMonth() {
    final nextDate = DateTime(_year, _month + 1, 1);
    // Не даём перейти в будущее
    if (nextDate.isBefore(DateTime.now()) || 
        (nextDate.month == DateTime.now().month && nextDate.year == DateTime.now().year)) {
      setState(() {
        _currentDate = nextDate;
      });
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

    if (_club == null) {
      return _buildEmptyState(context, isDark);
    }

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          _previousMonth();
        } else if (details.primaryVelocity! < 0) {
          _nextMonth();
        }
      },
      child: Column(
        children: [
          _buildHeader(context, isDark),
          const Divider(height: 1),
          Expanded(
            child: _rating?['has_games'] == true
                ? _buildRatingList(context, isDark)
                : _buildNoGamesPlaceholder(context, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people, size: 64, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Вы не состоите в клубе',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleLarge?.color ?? Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Вступите в клуб или создайте свой',
            style: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.black,
            ),
            child: const Text('Найти клуб'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final monthNames = [
      'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _previousMonth,
            color: Colors.orange,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  _club!['title'] ?? 'Клуб',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  '${monthNames[_month - 1]} $_year',
                  style: TextStyle(
                    color: isDark ? Colors.grey : Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextMonth,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildNoGamesPlaceholder(BuildContext context, bool isDark) {
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

  Widget _buildRatingList(BuildContext context, bool isDark) {
    final players = _rating!['players'] as List? ?? [];
    if (players.isEmpty) {
      return const Center(child: Text('Нет данных'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
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
                    color: index == 0 ? Colors.gold : 
                           index == 1 ? Colors.grey.shade400 : 
                           index == 2 ? Colors.brown.shade300 : Colors.transparent,
                    width: 1.5,
                  )
                : null,
          ),
          child: Row(
            children: [
              // Место
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
                      color: isTop ? Colors.white : (isDark ? Colors.grey : Colors.grey.shade600),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Имя
              Expanded(
                child: Text(
                  player['username'] ?? 'Игрок',
                  style: TextStyle(
                    fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              
              // Очки
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
}