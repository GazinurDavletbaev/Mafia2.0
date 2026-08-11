import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mafia_help/application/providers/club_provider.dart';
import 'package:mafia_help/application/providers/game_provider.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/services/auth_service.dart';
import 'package:path_provider/path_provider.dart';
import '../../../domain/rules/game_history.dart';

class ProtocolSaveLogic {
  final GameState gameState;
  final WidgetRef ref;

  final List<TextEditingController> noteControllers =
      List.generate(10, (_) => TextEditingController());
  final TextEditingController protestCommentController =
      TextEditingController();
  String _protestText = 'Нет';

  List<double> _bonusPoints = [];
  final Map<int, String> _removedRuleMap = {};

  ProtocolSaveLogic({
    required this.gameState,
    required this.ref,
  }) {
    _bonusPoints = List.generate(10, (_) => 0.0);
    _initRemovedRules();
  }

  void _initRemovedRules() {
    for (var p in gameState.removedPlayers) {
      _removedRuleMap[p.seatNumber] = '';
    }
  }

  void updateRemovedRule(int seatNumber, String rule) {
    _removedRuleMap[seatNumber] = rule;
  }

  void updateBonus(int index, double value) {
    _bonusPoints[index] = value;
  }

  void addRemovedNote(PlayerModel player, String rule) {
    final note = 'Игрок ${player.seatNumber} (${player.name}) был удален по $rule.';
    _addNote(note);
  }

  void addBonusNote(int index, double value) {
    if (value == 0) return;
    final player = gameState.players[index];
    final note = 'Игрок ${player.seatNumber} (${player.name}) получил ${value.toStringAsFixed(1)} балла.';
    _addNote(note);
  }

  void _addNote(String note) {
    for (int i = 0; i < noteControllers.length; i++) {
      if (noteControllers[i].text.isEmpty) {
        noteControllers[i].text = note;
        return;
      }
    }
    // Если все заняты — добавляем в первый
    noteControllers[0].text = noteControllers[0].text.isEmpty
        ? note
        : '${noteControllers[0].text}\n$note';
  }

  void dispose() {
    for (var c in noteControllers) {
      c.dispose();
    }
    protestCommentController.dispose();
  }

  Future<void> saveProtocol(BuildContext context) async {
    final notes = noteControllers.map((c) => c.text).toList();
    final protestComment = protestCommentController.text;

    // Проверка на дубликаты
    final playerNames = gameState.players.map((p) => p.name.trim()).toList();
    final duplicates = <String>[];
    final seen = <String>{};
    for (final name in playerNames) {
      if (name.isEmpty) continue;
      if (seen.contains(name)) {
        duplicates.add(name);
      } else {
        seen.add(name);
      }
    }
    if (duplicates.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Не может быть двух игроков с одинаковым именем: ${duplicates.join(", ")}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    // Получаем club_id
    final clubAsync = ref.watch(clubProvider);
    final clubId = clubAsync.when(
      data: (club) => club?['id'],
      loading: () => null,
      error: (_, __) => null,
    );

    // Формируем данные
    final isRedWon = gameState.winner == 'red';
    final points = gameState.players.map((p) {
      if (isRedWon) {
        return p.team == 'red' ? 1 : 0;
      } else {
        return p.team == 'black' ? 1 : 0;
      }
    }).toList();

    final data = {
      'club_id': clubId ?? 0,
      'tournament': gameState.tournamentName ?? 'РЕЙТИНГ',
      'stage': gameState.stageName ?? '',
      'table': gameState.tableNumber ?? 1,
      'game': gameState.gameNumber ?? 1,
      'date': gameState.gameDate?.toString().substring(0, 10) ?? DateTime.now().toString().substring(0, 10),
      'time': _formatTime(DateTime.now()),
      'judge': gameState.judgeName ?? '',
      'bestMove': gameState.partialBestMove.join(', '),
      'protest': _protestText,
      'protestComment': protestComment,
      'winner': gameState.winner,
      'players': gameState.players.map((p) {
        final isRemoved = gameState.removedPlayers.any((rp) => rp.seatNumber == p.seatNumber);
        final hasPpk = gameState.ppkPlayerSeat == p.seatNumber;

        double bonus;
        if (hasPpk) {
          bonus = -1.0;
        } else if (isRemoved) {
          bonus = -0.5;
        } else {
          bonus = _bonusPoints[p.seatNumber - 1];
        }

        final rule = isRemoved ? (_removedRuleMap[p.seatNumber] ?? '') : '';

        return {
          'seat': p.seatNumber,
          'name': p.name,
          'role': p.role,
          'fouls': p.fouls,
          'points': points[p.seatNumber - 1],
          'bonus': bonus,
          'rule': rule,
        };
      }).toList(),
      'nightActions': gameState.nightActions ?? [],
      'voteHistory': gameState.voteHistory.map((day, dayData) {
        final rounds = dayData.rounds.map((round) {
          return round.map((key, value) => MapEntry(key.toString(), value));
        }).toList();
        return MapEntry(day.toString(), {
          'rounds': rounds,
          'eliminated': dayData.eliminated,
          'eliminationVotes': dayData.eliminationVotes,
          'result': dayData.result,
        });
      }),
      'notes': notes,
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Не авторизован'), backgroundColor: Colors.red),
        );
        return;
      }

      bool savedToClub = false;
      if (clubId != null && clubId != 0) {
        final savedGameId = ref.read(savedGameIdProvider);
        final savedGameIdNotifier = ref.read(savedGameIdProvider.notifier);

        String url;
        if (savedGameId != null) {
          url = 'http://161.104.46.234:8001/games/update/$savedGameId?token=$token';
        } else {
          url = 'http://161.104.46.234:8001/games/save?token=$token';
        }

        final saveResponse = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        );

        if (saveResponse.statusCode == 200) {
          final responseData = jsonDecode(saveResponse.body);
          savedGameIdNotifier.state = responseData['game_id'];
          savedToClub = true;
        } else {
          final errorData = jsonDecode(saveResponse.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⚠️ Игра не сохранена в клуб: ${errorData['detail'] ?? 'Неизвестная ошибка'}'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      final excelResponse = await http.post(
        Uri.parse('http://161.104.46.234:8001/protocol/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      Navigator.pop(context);

      if (excelResponse.statusCode == 200) {
        final bytes = excelResponse.bodyBytes;
        final directory = await getApplicationDocumentsDirectory();
        final fileName =
            '${_dateString()}_${_formatTime(DateTime.now()).replaceAll(':', '-')}_${gameState.tableNumber ?? 1}_${gameState.gameNumber ?? 1}.xlsx';
        final path = '${directory.path}/$fileName';
        final file = File(path);
        await file.writeAsBytes(bytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(savedToClub ? '✅ Игра сохранена в клуб и Excel создан!' : '✅ Excel создан!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Excel не создан: ${excelResponse.statusCode}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Ошибка: $e'), backgroundColor: Colors.red),
      );
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _dateString() {
    return gameState.gameDate?.toString().substring(0, 10) ??
        DateTime.now().toString().substring(0, 10);
  }
}