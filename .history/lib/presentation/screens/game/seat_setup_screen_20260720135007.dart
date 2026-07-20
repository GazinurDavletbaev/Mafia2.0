// lib/presentation/screens/game/seat_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/presentation/screens/lobby_screen.dart';
import 'package:mafia_help/services/club_service.dart';
import 'package:mafia_help/application/providers/club_provider.dart';

class SeatSetupScreen extends ConsumerStatefulWidget {
  final GameData initialData;
  final Function(GameData) onNamesChanged;

  const SeatSetupScreen({
    super.key,
    required this.initialData,
    required this.onNamesChanged,
  });

  @override
  ConsumerState<SeatSetupScreen> createState() => _SeatSetupScreenState();
}

class _SeatSetupScreenState extends ConsumerState<SeatSetupScreen> {
  late List<TextEditingController> _nameControllers;
  List<Map<String, dynamic>> _clubMembers = [];
  List<Map<String, dynamic>> _filteredMembers = [];
  int _focusedIndex = -1;

  @override
  void initState() {
    super.initState();
    _nameControllers = List.generate(10, (index) {
      return TextEditingController(
        text: widget.initialData.playerNames.length > index
            ? widget.initialData.playerNames[index]
            : '',
      );
    });
    _loadClubMembers();
  }

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadClubMembers() async {
    final clubAsync = ref.read(clubProvider);
    final club = clubAsync.value;
    if (club != null) {
      final result = await ClubService.getClubMembers(club['id']);
      if (result['success']) {
        setState(() {
          _clubMembers =
              (result['members'] as List? ?? []).cast<Map<String, dynamic>>();
        });
      }
    }
  }

  void _notifyChanges() {
    final names = _nameControllers.map((c) => c.text.trim()).toList();

    final updatedPlayers =
        widget.initialData.gameState.players.asMap().entries.map((entry) {
      final index = entry.key;
      final player = entry.value;
      final name = names.length > index ? names[index] : player.name;
      return player.copyWith(name: name);
    }).toList();

    final updatedGameState = widget.initialData.gameState.copyWith(
      players: updatedPlayers,
    );

    widget.onNamesChanged(
      GameData(
        tournamentName: widget.initialData.tournamentName,
        stageName: widget.initialData.stageName,
        tableNumber: widget.initialData.tableNumber,
        gameNumber: widget.initialData.gameNumber,
        date: widget.initialData.date,
        judgeName: widget.initialData.judgeName,
        playerNames: names,
        gameState: updatedGameState,
        gameHistory: widget.initialData.gameHistory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final leftSeats = [5, 4, 3, 2, 1];
    final rightSeats = [6, 7, 8, 9, 10];

    // Восстанавливаем имена при возврате
    for (int i = 0; i < 10; i++) {
      final savedName = widget.initialData.playerNames.length > i
          ? widget.initialData.playerNames[i]
          : '';
      if (_nameControllers[i].text != savedName) {
        _nameControllers[i].text = savedName;
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _buildColumn(leftSeats, isLeft: true),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildColumn(rightSeats, isLeft: false),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumn(List<int> seats, {required bool isLeft}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: seats.map((seat) {
        final index = seat - 1;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$seat',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(index, seat, isLeft),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  
  }
}
