import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/club_provider.dart';
import 'package:mafia_help/presentation/screens/lobby/lobby_data.dart';
import 'package:mafia_help/presentation/widgets/seats/seat_search_overlay.dart';
import 'package:mafia_help/services/club_service.dart';

class SeatSetupViewModel extends ChangeNotifier {
  final WidgetRef ref;
  final GameData initialData;
  final Function(GameData) onNamesChanged;

  // ===== КОНТРОЛЛЕРЫ ДЛЯ ИМЁН =====
  late List<TextEditingController> nameControllers;
  late List<Map<String, dynamic>?> selectedPlayers;
  List<Map<String, dynamic>> clubMembers = [];
  List<Map<String, dynamic>> filteredMembers = [];
  int focusedIndex = -1;
  String searchQuery = '';
  final List<GlobalKey> textFieldKeys = List.generate(10, (index) => GlobalKey());

  // ===== КОНТРОЛЛЕРЫ ДЛЯ НАСТРОЕК =====
  late TextEditingController tournamentController;
  late TextEditingController stageController;
  late TextEditingController tableController;
  late TextEditingController gameController;
  late DateTime selectedDate;

  final List<String> months = [
    'ЯНВАРЬ', 'ФЕВРАЛЬ', 'МАРТ', 'АПРЕЛЬ', 'МАЙ', 'ИЮНЬ',
    'ИЮЛЬ', 'АВГУСТ', 'СЕНТЯБРЬ', 'ОКТЯБРЬ', 'НОЯБРЬ', 'ДЕКАБРЬ'
  ];

  SeatSetupViewModel({
    required this.ref,
    required this.initialData,
    required this.onNamesChanged,
  }) {
    _initControllers();
    _initSettingsControllers();
    _loadClubMembers();
  }

  void _initControllers() {
    nameControllers = List.generate(10, (index) {
      return TextEditingController(
        text: initialData.playerNames.length > index
            ? initialData.playerNames[index]
            : '',
      );
    });
    selectedPlayers = List.generate(10, (index) => null);
  }

  void _initSettingsControllers() {
    final initialStage = initialData.stageName.isNotEmpty
        ? initialData.stageName
        : months[DateTime.now().month - 1];

    tournamentController = TextEditingController(
      text: initialData.tournamentName,
    );
    stageController = TextEditingController(
      text: initialStage,
    );
    tableController = TextEditingController(
      text: initialData.tableNumber.toString(),
    );
    gameController = TextEditingController(
      text: initialData.gameNumber.toString(),
    );
    selectedDate = initialData.date;
  }

  void dispose() {
    for (var controller in nameControllers) {
      controller.dispose();
    }
    tournamentController.dispose();
    stageController.dispose();
    tableController.dispose();
    gameController.dispose();
    SeatSearchOverlay.close();
  }

  void resetSeats() {
    SeatSearchOverlay.close();

    for (var controller in nameControllers) {
      controller.clear();
    }

    selectedPlayers = List.generate(10, (index) => null);
    focusedIndex = -1;
    searchQuery = '';
    filteredMembers = List.from(clubMembers);

    notifyChanges();
    notifyListeners();
  }

  void updateFilteredList() {
    final q = searchQuery.toLowerCase().trim();
    
    final takenUsernames = <String>{};
    for (int i = 0; i < selectedPlayers.length; i++) {
      if (focusedIndex >= 0 && i == focusedIndex) continue;

      final selected = selectedPlayers[i];
      if (selected != null) {
        final username = selected['username'];
        if (username != null && username.isNotEmpty) {
          takenUsernames.add(username);
        }
      }
    }

    if (q.isEmpty) {
      filteredMembers = clubMembers
          .where((m) => !takenUsernames.contains(m['username']))
          .toList();
    } else {
      filteredMembers = clubMembers
          .where((m) =>
              (m['username'] ?? '').toLowerCase().contains(q) &&
              !takenUsernames.contains(m['username']))
          .toList();
    }
    notifyListeners();
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

    clubMembers = allPlayers;
    filteredMembers = List.from(allPlayers);
    notifyListeners();
  }

  void notifyChanges() {
    final names = nameControllers.map((c) => c.text.trim()).toList();

    final updatedPlayers =
        initialData.gameState.players.asMap().entries.map((entry) {
      final index = entry.key;
      final player = entry.value;
      final newName = names.length > index ? names[index] : player.name;
      final oldName = player.name;

      if (newName == oldName) {
        return player;
      }

      final selected = selectedPlayers[index];
      final int? userId = selected != null ? selected['id'] as int? : null;
      final String? avatarUrl =
          (userId != null) ? selected!['avatar_url'] as String? : '';

      return player.copyWith(
        name: newName,
        avatarUrl: avatarUrl,
        userId: userId,
      );
    }).toList();

    final updatedGameState = initialData.gameState.copyWith(
      players: updatedPlayers,
      tournamentName: tournamentController.text,
      stageName: stageController.text,
      tableNumber: int.tryParse(tableController.text) ?? 1,
      gameNumber: int.tryParse(gameController.text) ?? 1,
      gameDate: selectedDate,
    );

    onNamesChanged(
      GameData(
        tournamentName: tournamentController.text,
        stageName: stageController.text,
        tableNumber: int.tryParse(tableController.text) ?? 1,
        gameNumber: int.tryParse(gameController.text) ?? 1,
        date: selectedDate,
        judgeName: initialData.judgeName,
        playerNames: names,
        gameState: updatedGameState,
        gameHistory: initialData.gameHistory,
      ),
    );
  }

  void selectDateTime(DateTime date, TimeOfDay time) {
    selectedDate = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    stageController.text = months[selectedDate.month - 1];
    notifyChanges();
    notifyListeners();
  }

  void onPlayerTap(int index, BuildContext context) {
    focusedIndex = index;
    searchQuery = nameControllers[index].text;
    updateFilteredList();

    SeatSearchOverlay.show(
      context: context,
      textFieldKey: textFieldKeys[index],
      members: filteredMembers,
      onSelect: (member) {
        selectedPlayers[index] = member;
        nameControllers[index].text = member['username'] ?? '';
        filteredMembers = [];
        focusedIndex = -1;
        searchQuery = '';
        notifyChanges();
        notifyListeners();
      },
      onClose: () {
        SeatSearchOverlay.close();
        filteredMembers = [];
        focusedIndex = -1;
        searchQuery = '';
        notifyListeners();
      },
    );
  }

  void onPlayerChanged(int index, String value) {
    searchQuery = value;
    focusedIndex = index;
    updateFilteredList();
    notifyChanges();

    if (SeatSearchOverlay.isVisible) {
      // Обновляем оверлей
    }
  }

  void updateControllersFromData() {
    for (int i = 0; i < 10; i++) {
      final savedName = initialData.playerNames.length > i
          ? initialData.playerNames[i]
          : '';
      if (nameControllers[i].text != savedName) {
        nameControllers[i].text = savedName;
      }
    }
  }
}

final seatSetupViewModelProvider = ChangeNotifierProvider.family<SeatSetupViewModel, SeatSetupViewModelParams>(
  (ref, params) => SeatSetupViewModel(
    ref: ref,
    initialData: params.initialData,
    onNamesChanged: params.onNamesChanged,
  ),
);

class SeatSetupViewModelParams {
  final GameData initialData;
  final Function(GameData) onNamesChanged;

  SeatSetupViewModelParams({
    required this.initialData,
    required this.onNamesChanged,
  });
}