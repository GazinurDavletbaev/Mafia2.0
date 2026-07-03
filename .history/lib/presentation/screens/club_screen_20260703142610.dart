// lib/presentation/screens/club_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/update_service.dart';
import 'saved_protocols_screen.dart';
import 'settings_screen.dart';

class ClubScreen extends ConsumerStatefulWidget {
  const ClubScreen({super.key});

  @override
  ConsumerState<ClubScreen> createState() => _ClubScreenState();
}

class _ClubScreenState extends ConsumerState<ClubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        UpdateService.checkForUpdate(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ✅ Генерируем 40 игроков
    final List<Map<String, dynamic>> players = _generatePlayers(40);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(
          'Рейтинг клуба',
          style: TextStyle(color: theme.appBarTheme.foregroundColor),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open, color: Colors.orange),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SavedProtocolsScreen(),
                ),
              );
            },
            tooltip: 'Сохранённые игры',
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.orange),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            tooltip: 'Настройки',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            const Text(
              'Рейтинг игроков',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      width: 
                      columnSpacing: 9,
                      horizontalMargin: 9,
                      headingRowColor: WidgetStateProperty.resolveWith<Color>(
                        (_) => isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                      ),
                      headingTextStyle: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      dataTextStyle: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 12,
                      ),
                      columns: const [
                        DataColumn(
                            label: Text(
                          '№',
                        )),
                        DataColumn(label: Text('Игрок')),
                        DataColumn(label: Text('Игры'), numeric: true),
                        DataColumn(label: Text('Победы'), numeric: true),
                        DataColumn(label: Text('Баллы'), numeric: true),
                        DataColumn(label: Text('Доп.'), numeric: true),
                        DataColumn(label: Text('ЛХ'), numeric: true),
                      ],
                      rows: players.asMap().entries.map((entry) {
                        final index = entry.key;
                        final player = entry.value;
                        final place = index + 1;
                        final isTop = place <= 3;

                        return DataRow(
                          color: WidgetStateProperty.resolveWith<Color>(
                            (_) {
                              if (isTop) {
                                return Colors.orange.withOpacity(0.15);
                              }
                              return Colors.transparent;
                            },
                          ),
                          cells: [
                            DataCell(
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: _getPlaceColor(place),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '$place',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                player['name'],
                                style: TextStyle(
                                  fontWeight: isTop
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            DataCell(Text('${player['games']}')),
                            DataCell(Text('${player['wins']}')),
                            DataCell(
                              Text(
                                '${player['points']}',
                                style: TextStyle(
                                  fontWeight: isTop
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isTop ? Colors.orange : null,
                                ),
                              ),
                            ),
                            DataCell(Text('${player['bonus']}')),
                            DataCell(Text('${player['bestMove']}')),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _generatePlayers(int count) {
    final names = [
      'Алексей',
      'Дмитрий',
      'Сергей',
      'Иван',
      'Петр',
      'Михаил',
      'Андрей',
      'Николай',
      'Олег',
      'Владимир',
      'Артем',
      'Максим',
      'Антон',
      'Егор',
      'Роман',
      'Денис',
      'Виктор',
      'Юрий',
      'Анатолий',
      'Константин',
      'Вячеслав',
      'Григорий',
      'Павел',
      'Василий',
      'Тимофей',
      'Илья',
      'Никита',
      'Матвей',
      'Захар',
      'Ярослав',
      'Степан',
      'Кирилл',
      'Александр',
      'Евгений',
      'Глеб',
      'Даниил',
      'Федор',
      'Лев',
      'Марк',
      'Борис',
    ];

    final players = <Map<String, dynamic>>[];
    for (int i = 0; i < count && i < names.length; i++) {
      final games = 5 + (i % 10);
      final wins = (games * 0.4 + (i % 5)).round();
      final points = games * 2 + (i % 7);
      final bonus = (i % 5) * 0.1;
      final bestMove = 1 + (i % 9);

      players.add({
        'name': names[i % names.length],
        'games': games,
        'wins': wins,
        'points': points,
        'bonus': bonus.toStringAsFixed(1),
        'bestMove': bestMove,
      });
    }
    return players;
  }

  Color _getPlaceColor(int place) {
    switch (place) {
      case 1:
        return Colors.orange.shade700;
      case 2:
        return Colors.grey.shade600;
      case 3:
        return Colors.brown.shade600;
      default:
        return Colors.grey.shade500;
    }
  }
}
