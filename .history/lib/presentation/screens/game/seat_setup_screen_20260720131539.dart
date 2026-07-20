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
  List<Map<String, dynamic>> _clubMembers = []; // ✅ список участников клуба
  bool _isLoadingMembers = false; // ✅ статус загрузки

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
    _loadClubMembers(); // ✅ загружаем участников
  }

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // ✅ Загрузка участников клуба
  Future<void> _loadClubMembers() async {
    setState(() => _isLoadingMembers = true);

    final clubAsync = ref.read(clubProvider);
    final club = clubAsync.value;

    if (club != null) {
      final result = await ClubService.getClubMembers(club['id']);
      if (result['success']) {
        _clubMembers =
            (result['members'] as List? ?? []).cast<Map<String, dynamic>>();
      }
    }

    setState(() => _isLoadingMembers = false);
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

    final updatedGameState =
        widget.initialData.gameState.copyWith(players: updatedPlayers);

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

  // ✅ Фильтрация участников по запросу
  List<Map<String, dynamic>> _getFilteredMembers(String query) {
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase().trim();
    return _clubMembers.where((member) {
      final username = member['username']?.toLowerCase() ?? '';
      return username.contains(lowerQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final leftSeats = [5, 4, 3, 2, 1];
    final rightSeats = [6, 7, 8, 9, 10];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            if (_isLoadingMembers) const LinearProgressIndicator(),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildColumn(leftSeats, isLeft: true)),
                  const SizedBox(width: 20),
                  Expanded(child: _buildColumn(rightSeats, isLeft: false)),
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
                      color: Colors.grey, shape: BoxShape.circle),
                  child: Center(
                    child: Text('$seat',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                                child: _buildTextFieldWithSearch(index, isLeft), // ← ЗАМЕНИЛИ

                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextFieldWithSearch(int index, bool isLeft) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = _nameControllers[index];

    return Autocomplete<Map<String, dynamic>>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Map<String, dynamic>>.empty();
        }
        return _getFilteredMembers(textEditingValue.text);
      },
      displayStringForOption: (Map<String, dynamic> option) {
        return option['username'] ?? '';
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        // ✅ Связываем контроллеры
        controller.addListener(() {
          if (controller.text != textEditingController.text) {
            textEditingController.text = controller.text;
            textEditingController.selection = TextSelection.fromPosition(
              TextPosition(offset: controller.text.length),
            );
          }
        });

        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          style: TextStyle(
              color: theme.textTheme.bodyLarge?.color ?? Colors.white),
          onChanged: (_) {
            controller.text = textEditingController.text;
            _notifyChanges();
          },
          decoration: InputDecoration(
            hintText: 'Игрок ${index + 1}',
            hintStyle: TextStyle(
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
            filled: true,
            fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          textAlign: isLeft ? TextAlign.left : TextAlign.right,
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final optionsList = options.toList();
        if (optionsList.isEmpty) {
          return const SizedBox.shrink();
        }

        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: isDark ? Colors.grey.shade800 : Colors.white,
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 300,
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: optionsList.length,
                itemBuilder: (context, i) {
                  final member = optionsList[i];
                  return ListTile(
                    title: Text(
                      member['username'] ?? 'Неизвестен',
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87),
                    ),
                    subtitle: Text(
                      member['email'] ?? '',
                      style: TextStyle(
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          fontSize: 12),
                    ),
                    onTap: () {
                      controller.text = member['username'] ?? '';
                      _notifyChanges();
                      onSelected(member);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
      onSelected: (Map<String, dynamic> selection) {},
    );
  }
}
