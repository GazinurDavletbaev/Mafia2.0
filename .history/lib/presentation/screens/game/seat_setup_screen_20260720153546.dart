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
  late List<Map<String, dynamic>?> _selectedPlayers;
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
    _selectedPlayers =
        List.generate(10, (index) => null); // ← ДОБАВЬ ЭТУ СТРОКУ

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
    final avatars =
        _selectedPlayers.map((p) => p?['avatar_url']).toList(); // ✅ ДОБАВИТЬ

    final updatedPlayers =
        widget.initialData.gameState.players.asMap().entries.map((entry) {
      final index = entry.key;
      final player = entry.value;
      final name = names.length > index ? names[index] : player.name;
      final avatar =
          avatars.length > index ? avatars[index] : player.avatarUrl; // ✅
      return player.copyWith(
        name: name,
        avatarUrl: avatar, // ✅
      );
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

  Widget _buildTextField(int index, int seat, bool isLeft) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = _nameControllers[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color ?? Colors.white,
          ),
          onChanged: (value) {
            setState(() {
              _focusedIndex = index;
              final q = value.toLowerCase().trim();
              if (q.isNotEmpty) {
                _filteredMembers = _clubMembers
                    .where(
                        (m) => (m['username'] ?? '').toLowerCase().contains(q))
                    .toList();
              } else {
                _filteredMembers = [];
              }
            });
            _notifyChanges();
          },
          onTap: () {
            if (controller.text.isNotEmpty) {
              setState(() {
                _focusedIndex = index;
                final q = controller.text.toLowerCase().trim();
                _filteredMembers = _clubMembers
                    .where(
                        (m) => (m['username'] ?? '').toLowerCase().contains(q))
                    .toList();
              });
            }
          },
          decoration: InputDecoration(
            hintText: 'Игрок $seat',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            filled: true,
            fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          textAlign: isLeft ? TextAlign.left : TextAlign.right,
        ),
        if (_focusedIndex == index && _filteredMembers.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: double.infinity, // ✅ На всю ширину
            constraints:
                const BoxConstraints(maxHeight: 150), // ✅ Максимальная высота
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true, // ✅ Занимает только нужную высоту
              itemCount: _filteredMembers.length,
              itemBuilder: (context, i) {
                final member = _filteredMembers[i];
                final avatarUrl = member['avatar_url'];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundImage:
                        avatarUrl != null && avatarUrl.toString().isNotEmpty
                            ? NetworkImage(avatarUrl)
                            : null,
                    child: avatarUrl == null || avatarUrl.toString().isEmpty
                        ? Image.asset(
                            'assets/mafia_logo.png',
                            width: 20,
                            height: 20,
                            fit: BoxFit.contain,
                          )
                        : null,
                  ),
                  title: Text(
                    member['username'] ?? '',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedPlayers[index] = member;
                      controller.text = member['username'] ?? '';
                      _filteredMembers = [];
                      _focusedIndex = -1;
                    });
                    _notifyChanges();
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
