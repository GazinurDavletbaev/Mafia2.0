import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/club_provider.dart';
import 'package:mafia_help/presentation/screens/lobby/lobby_data.dart';
import 'package:mafia_help/presentation/widgets/seats/seat_search_overlay.dart';
import 'package:mafia_help/services/club_service.dart';

// ===== СОСТОЯНИЕ =====
class SeatSetupState {
  final List<TextEditingController> nameControllers;
  final List<Map<String, dynamic>?> selectedPlayers;
  final List<Map<String, dynamic>> clubMembers;
  final List<Map<String, dynamic>> filteredMembers;
  final int focusedIndex;
  final String searchQuery;
  final List<GlobalKey> textFieldKeys;
  final TextEditingController tournamentController;
  final TextEditingController stageController;
  final TextEditingController tableController;
  final TextEditingController gameController;
  final DateTime selectedDate;
  final List<String> months;
    final List<String> avatarUrls;  // 🔥 ДОБАВЛЯЕМ


  SeatSetupState({
    required this.nameControllers,
    required this.selectedPlayers,
    required this.clubMembers,
    required this.filteredMembers,
    required this.focusedIndex,
    required this.searchQuery,
    required this.textFieldKeys,
    required this.tournamentController,
    required this.stageController,
    required this.tableController,
    required this.gameController,
    required this.selectedDate,
    required this.months,
    required this.avatarUrls,
  });

  SeatSetupState copyWith({
    List<TextEditingController>? nameControllers,
    List<Map<String, dynamic>?>? selectedPlayers,
    List<Map<String, dynamic>>? clubMembers,
    List<Map<String, dynamic>>? filteredMembers,
    int? focusedIndex,
    String? searchQuery,
    List<GlobalKey>? textFieldKeys,
    TextEditingController? tournamentController,
    TextEditingController? stageController,
    TextEditingController? tableController,
    TextEditingController? gameController,
    DateTime? selectedDate,
    List<String>? months,
    List<String> avatarUrls,  // 🔥 ДОБАВЛЯЕМ

  }) {
    return SeatSetupState(
      nameControllers: nameControllers ?? this.nameControllers,
      selectedPlayers: selectedPlayers ?? this.selectedPlayers,
      clubMembers: clubMembers ?? this.clubMembers,
      filteredMembers: filteredMembers ?? this.filteredMembers,
      focusedIndex: focusedIndex ?? this.focusedIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      textFieldKeys: textFieldKeys ?? this.textFieldKeys,
      tournamentController: tournamentController ?? this.tournamentController,
      stageController: stageController ?? this.stageController,
      tableController: tableController ?? this.tableController,
      gameController: gameController ?? this.gameController,
      selectedDate: selectedDate ?? this.selectedDate,
      months: months ?? this.months,
      avatarUrls: avatarUrls
    );
  }
}

// ===== NOTIFIER =====
class SeatSetupNotifier extends StateNotifier<SeatSetupState> {
  final Ref ref;
  final GameData initialData;
  final Function(GameData) onNamesChanged;

  SeatSetupNotifier({
    required this.ref,
    required this.initialData,
    required this.onNamesChanged,
  }) : super(_createInitialState(initialData)) {
    _loadClubMembers();
  }

  static SeatSetupState _createInitialState(GameData initialData) {
    final months = [
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

    final nameControllers = List.generate(10, (index) {
      return TextEditingController(
        text: initialData.playerNames.length > index
            ? initialData.playerNames[index]
            : '',
      );
    });

    final initialStage = initialData.stageName.isNotEmpty
        ? initialData.stageName
        : months[DateTime.now().month - 1];

    return SeatSetupState(
      nameControllers: nameControllers,
      selectedPlayers: List.generate(10, (index) => null),
      clubMembers: [],
      filteredMembers: [],
      focusedIndex: -1,
      searchQuery: '',
      textFieldKeys: List.generate(10, (index) => GlobalKey()),
      tournamentController: TextEditingController(
        text: initialData.tournamentName,
      ),
      stageController: TextEditingController(
        text: initialStage,
      ),
      tableController: TextEditingController(
        text: initialData.tableNumber.toString(),
      ),
      gameController: TextEditingController(
        text: initialData.gameNumber.toString(),
      ),
      selectedDate: initialData.date,
      months: months,
    );
  }

  @override
  void dispose() {
    // 🔥 Вызываем super.dispose()
    super.dispose();

    if (state.nameControllers.isNotEmpty) {
      for (var controller in state.nameControllers) {
        controller.dispose();
      }
    }
    state.tournamentController.dispose();
    state.stageController.dispose();
    state.tableController.dispose();
    state.gameController.dispose();
    SeatSearchOverlay.close();
  }

  void resetSeats() {
    SeatSearchOverlay.close();

    for (var controller in state.nameControllers) {
      controller.clear();
    }

    state = state.copyWith(
      selectedPlayers: List.generate(10, (index) => null),
      focusedIndex: -1,
      searchQuery: '',
      filteredMembers: List.from(state.clubMembers),
    );

    notifyChanges();
  }

  void updateFilteredList() {
    final q = state.searchQuery.toLowerCase().trim();

    final takenUsernames = <String>{};

    // 🔥 Берём имена ТОЛЬКО из контроллеров (всех полей)
    for (int i = 0; i < state.nameControllers.length; i++) {
      // Пропускаем текущее поле (которое в фокусе)
      if (state.focusedIndex >= 0 && i == state.focusedIndex) continue;

      final text = state.nameControllers[i].text.trim();
      if (text.isNotEmpty) {
        takenUsernames.add(text);
      }
    }

    print("🔍 takenUsernames: $takenUsernames");

    List<Map<String, dynamic>> filtered;
    if (q.isEmpty) {
      filtered = state.clubMembers
          .where((m) => !takenUsernames.contains(m['username']))
          .toList();
    } else {
      filtered = state.clubMembers
          .where((m) =>
              (m['username'] ?? '').toLowerCase().contains(q) &&
              !takenUsernames.contains(m['username']))
          .toList();
    }

    print("🔍 filtered count: ${filtered.length}");
    state = state.copyWith(filteredMembers: filtered);
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

    state = state.copyWith(
      clubMembers: allPlayers,
      filteredMembers: List.from(allPlayers),
    );
  }

  void notifyChanges() {
    final names = state.nameControllers.map((c) => c.text.trim()).toList();

    final updatedPlayers =
        initialData.gameState.players.asMap().entries.map((entry) {
      final index = entry.key;
      final player = entry.value;
      final newName = names.length > index ? names[index] : player.name;
      final oldName = player.name;

      if (newName == oldName) {
        return player;
      }

      final selected = state.selectedPlayers[index];
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
      tournamentName: state.tournamentController.text,
      stageName: state.stageController.text,
      tableNumber: int.tryParse(state.tableController.text) ?? 1,
      gameNumber: int.tryParse(state.gameController.text) ?? 1,
      gameDate: state.selectedDate,
    );

    onNamesChanged(
      GameData(
        tournamentName: state.tournamentController.text,
        stageName: state.stageController.text,
        tableNumber: int.tryParse(state.tableController.text) ?? 1,
        gameNumber: int.tryParse(state.gameController.text) ?? 1,
        date: state.selectedDate,
        judgeName: initialData.judgeName,
        playerNames: names,
        gameState: updatedGameState,
        gameHistory: initialData.gameHistory,
      ),
    );
  }

  void selectDateTime(DateTime date, TimeOfDay time) {
    final newDate = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    state.stageController.text = state.months[newDate.month - 1];
    state = state.copyWith(selectedDate: newDate);
    notifyChanges();
  }

  void onPlayerTap(int index, BuildContext context) {
    state = state.copyWith(
      focusedIndex: index,
      searchQuery: state.nameControllers[index].text,
    );
    updateFilteredList();

    // 🔥 Закрываем старый оверлей, если открыт
    if (SeatSearchOverlay.isVisible) {
      SeatSearchOverlay.close();
    }

    // Открываем новый
    SeatSearchOverlay.show(
      context: context,
      textFieldKey: state.textFieldKeys[index],
      members: state.filteredMembers,
      onSelect: (member) {
        final newSelectedPlayers =
            List<Map<String, dynamic>?>.from(state.selectedPlayers);
        newSelectedPlayers[index] = member;
        state.nameControllers[index].text = member['username'] ?? '';

        state = state.copyWith(
          selectedPlayers: newSelectedPlayers,
          filteredMembers: [],
          focusedIndex: -1,
          searchQuery: '',
        );
        SeatSearchOverlay.close();
        notifyChanges();
      },
      onClose: () {
        state = state.copyWith(
          filteredMembers: [],
          focusedIndex: -1,
          searchQuery: '',
        );
      },
    );
  }

  void onPlayerChanged(int index, String value) {
    state = state.copyWith(
      searchQuery: value,
      focusedIndex: index,
    );

    updateFilteredList();
    if (SeatSearchOverlay.isVisible) {
      SeatSearchOverlay.update(members: state.filteredMembers);
    }
  }

  void updateControllersFromData() {
    for (int i = 0; i < 10; i++) {
      final savedName =
          initialData.playerNames.length > i ? initialData.playerNames[i] : '';
      if (state.nameControllers[i].text != savedName) {
        state.nameControllers[i].text = savedName;
      }
    }
  }
}

// ===== PROVIDER =====
final seatSetupProvider =
    StateNotifierProvider<SeatSetupNotifier, SeatSetupState>((ref) {
  throw UnimplementedError('Use seatSetupProviderFamily with params');
});

final seatSetupProviderFamily = StateNotifierProvider.family<SeatSetupNotifier,
    SeatSetupState, SeatSetupParams>(
  (ref, params) => SeatSetupNotifier(
    ref: ref,
    initialData: params.initialData,
    onNamesChanged: params.onNamesChanged,
  ),
);

class SeatSetupParams {
  final GameData initialData;
  final Function(GameData) onNamesChanged;

  SeatSetupParams({
    required this.initialData,
    required this.onNamesChanged,
  });
}
