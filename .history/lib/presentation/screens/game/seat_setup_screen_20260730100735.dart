// lib/presentation/screens/game/seat_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/presentation/screens/lobby/lobby_data.dart';
import 'package:mafia_help/presentation/widgets/game/game_new_button.dart';
import 'package:mafia_help/presentation/widgets/seats/seat_player_list.dart';
import 'package:mafia_help/presentation/widgets/seats/seat_search_overlay.dart';
import 'package:mafia_help/presentation/widgets/seats/seat_settings_row.dart';
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
  // ===== КОНТРОЛЛЕРЫ ДЛЯ ИМЁН =====
  late List<TextEditingController> _nameControllers;
  late List<Map<String, dynamic>?> _selectedPlayers;
  List<Map<String, dynamic>> _clubMembers = [];
  List<Map<String, dynamic>> _filteredMembers = [];
  int _focusedIndex = -1;
  String _searchQuery = '';
  final List<GlobalKey> _textFieldKeys =
      List.generate(10, (index) => GlobalKey());

  // ===== КОНТРОЛЛЕРЫ ДЛЯ НАСТРОЕК =====
  late TextEditingController _tournamentController;
  late TextEditingController _stageController;
  late TextEditingController _tableController;
  late TextEditingController _gameController;
  late DateTime _selectedDate;

  final List<String> _months = [
    'ЯНВАРЬ',
    'ФЕВРАЛЬ',
    'МАРТ',
    'АПРЕЛЬ',
    'МАЙ',
    'ИЮНЬ',
    'ИЮЛЬ',
    'АВГУСТ',
    'СЕНТЯБРЬ',
    'ОКТЯБРЬ',
    'НОЯБРЬ',
    'ДЕКАБРЬ'
  ];

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initSettingsControllers();
    _loadClubMembers();
  }

  void _initControllers() {
    _nameControllers = List.generate(10, (index) {
      return TextEditingController(
        text: widget.initialData.playerNames.length > index
            ? widget.initialData.playerNames[index]
            : '',
      );
    });
    _selectedPlayers = List.generate(10, (index) => null);
  }

  void _initSettingsControllers() {
    final initialStage = widget.initialData.stageName.isNotEmpty
        ? widget.initialData.stageName
        : _months[DateTime.now().month - 1];

    _tournamentController = TextEditingController(
      text: widget.initialData.tournamentName,
    );
    _stageController = TextEditingController(
      text: initialStage,
    );
    _tableController = TextEditingController(
      text: widget.initialData.tableNumber.toString(),
    );
    _gameController = TextEditingController(
      text: widget.initialData.gameNumber.toString(),
    );
    _selectedDate = widget.initialData.date;
  }

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    _tournamentController.dispose();
    _stageController.dispose();
    _tableController.dispose();
    _gameController.dispose();
    SeatSearchOverlay.close();
    super.dispose();
  }

  void _resetSeats() {
    SeatSearchOverlay.close();

    for (var controller in _nameControllers) {
      controller.clear();
    }

    setState(() {
      _selectedPlayers = List.generate(10, (index) => null);
      _focusedIndex = -1;
      _searchQuery = '';
      _filteredMembers = List.from(_clubMembers);
    });

    _notifyChanges();
  }

  void _updateFilteredList() {
    final q = _searchQuery.toLowerCase().trim();
    setState(() {
      final takenUsernames = <String>{};
      for (int i = 0; i < _selectedPlayers.length; i++) {
        if (_focusedIndex >= 0 && i == _focusedIndex) continue;

        final selected = _selectedPlayers[i];
        if (selected != null) {
          final username = selected['username'];
          if (username != null && username.isNotEmpty) {
            takenUsernames.add(username);
          }
        }
      }

      if (q.isEmpty) {
        _filteredMembers = _clubMembers
            .where((m) => !takenUsernames.contains(m['username']))
            .toList();
      } else {
        _filteredMembers = _clubMembers
            .where((m) =>
                (m['username'] ?? '').toLowerCase().contains(q) &&
                !takenUsernames.contains(m['username']))
            .toList();
      }
    });
  }

  Future<void> _loadClubMembers() async {
    final clubAsync = ref.read(clubProvider);
    final club = clubAsync.value;
    if (club == null) return;

    final membersResult = await ClubService.getClubMembers(club['id']);
    final List<Map<String, dynamic>> allPlayers = [];

    if (membersResult['success']) {
      final members = (membersResult['members'] as List? ?? [])
          .cast<Map<String, dynamic>>();
      allPlayers.addAll(members);
    }

    final now = DateTime.now();
    final ratingResult = await ClubService.getClubRating(
      clubId: club['id'],
      month: now.month,
      year: now.year,
    );

    if (ratingResult['success'] && ratingResult['has_games'] == true) {
      final ratingPlayers =
          (ratingResult['players'] as List? ?? []).cast<Map<String, dynamic>>();

      for (var player in ratingPlayers) {
        final username = player['username'] ?? '';
        final alreadyExists = allPlayers.any((m) => m['username'] == username);

        if (!alreadyExists) {
          allPlayers.add({
            'id': null,
            'username': username,
            'avatar_url': null,
            'email': null,
            'is_president': false,
            'is_judge': false,
            'joined_at': null,
          });
        }
      }
    }

    setState(() {
      _clubMembers = allPlayers;
      _filteredMembers = List.from(allPlayers);
    });
  }

  void _notifyChanges() {
    final names = _nameControllers.map((c) => c.text.trim()).toList();

    final updatedPlayers =
        widget.initialData.gameState.players.asMap().entries.map((entry) {
      final index = entry.key;
      final player = entry.value;
      final newName = names.length > index ? names[index] : player.name;
      final oldName = player.name;

      if (newName == oldName) {
        return player;
      }

      final selected = _selectedPlayers[index];
      final int? userId = selected != null ? selected['id'] as int? : null;
      final String? avatarUrl =
          (userId != null) ? selected!['avatar_url'] as String? : '';

      return player.copyWith(
        name: newName,
        avatarUrl: avatarUrl,
        userId: userId,
      );
    }).toList();

    final updatedGameState = widget.initialData.gameState.copyWith(
      players: updatedPlayers,
      tournamentName: _tournamentController.text,
      stageName: _stageController.text,
      tableNumber: int.tryParse(_tableController.text) ?? 1,
      gameNumber: int.tryParse(_gameController.text) ?? 1,
      gameDate: _selectedDate,
    );

    widget.onNamesChanged(
      GameData(
        tournamentName: _tournamentController.text,
        stageName: _stageController.text,
        tableNumber: int.tryParse(_tableController.text) ?? 1,
        gameNumber: int.tryParse(_gameController.text) ?? 1,
        date: _selectedDate,
        judgeName: widget.initialData.judgeName,
        playerNames: names,
        gameState: updatedGameState,
        gameHistory: widget.initialData.gameHistory,
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final theme = Theme.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.orange,
              onPrimary: Colors.black,
              surface: Colors.grey,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
        builder: (context, child) {
          return Theme(
            data: theme.copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Colors.orange,
                onPrimary: Colors.black,
                surface: Colors.grey,
                onSurface: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );
      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
          _stageController.text = _months[_selectedDate.month - 1];
          _notifyChanges();
        });
      }
    }
  }

  void _onPlayerTap(int index) {
    _focusedIndex = index;
    _searchQuery = _nameControllers[index].text;
    _updateFilteredList();

    SeatSearchOverlay.show(
      context: context,
      textFieldKey: _textFieldKeys[index],
      members: _filteredMembers,
      onSelect: (member) {
        setState(() {
          _selectedPlayers[index] = member;
          _nameControllers[index].text = member['username'] ?? '';
          _filteredMembers = [];
          _focusedIndex = -1;
          _searchQuery = '';
        });
        _notifyChanges();
      },
      onClose: () {
        SeatSearchOverlay.close();
        setState(() {
          _filteredMembers = [];
          _focusedIndex = -1;
          _searchQuery = '';
        });
      },
    );
  }

  void _onPlayerChanged(int index, String value) {
    _searchQuery = value;
    _focusedIndex = index;
    _updateFilteredList();
    _notifyChanges();

    if (SeatSearchOverlay.isVisible) {
      _onPlayerTap(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final leftSeats = [5, 4, 3, 2, 1];
    final rightSeats = [6, 7, 8, 9, 10];

    // Обновляем контроллеры если изменились данные
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
            // ===== ИГРОКИ =====
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: SeatPlayerList(
                      seats: leftSeats,
                      isLeft: true,
                      controllers: _nameControllers,
                      textFieldKeys: _textFieldKeys,
                      onTap: _onPlayerTap,
                      onChanged: _onPlayerChanged,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: SeatPlayerList(
                      seats: rightSeats,
                      isLeft: false,
                      controllers: _nameControllers,
                      textFieldKeys: _textFieldKeys,
                      onTap: _onPlayerTap,
                      onChanged: _onPlayerChanged,
                    ),
                  ),
                ],
              ),
            ),
            // ===== НАСТРОЙКИ =====
            const SizedBox(height: 8),
            SeatSettingsRow(
              tournamentController: _tournamentController,
              stageController: _stageController,
              tableController: _tableController,
              gameController: _gameController,
              selectedDate: _selectedDate,
              months: _months,
              onDateTap: () => _selectDateTime(context),
              onChanged: _notifyChanges,
            ),
            const SizedBox(height: 8),
            // ===== КНОПКА НОВАЯ ИГРА =====
            GameNewButton(
              label: 'СОЗДАТЬ НОВУЮ ИГРУ',
              isFullWidth: true,
              onNewGame: _resetSeats,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
