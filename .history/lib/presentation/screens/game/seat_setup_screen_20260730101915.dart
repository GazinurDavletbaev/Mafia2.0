// lib/presentation/screens/game/seat_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/presentation/screens/lobby/lobby_data.dart';
import 'package:mafia_help/presentation/viewmodel/seat_setup_viewmodel.dart';
import 'package:mafia_help/presentation/widgets/game/game_new_button.dart';
import 'package:mafia_help/presentation/widgets/seats/seat_player_list.dart';
import 'package:mafia_help/presentation/widgets/seats/seat_settings_row.dart';

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
  late SeatSetupParams _params;

  @override
  void initState() {
    super.initState();
    _params = SeatSetupParams(
      initialData: widget.initialData,
      onNamesChanged: widget.onNamesChanged,
    );
  }

  @override
  void dispose() {
    // 🔥 Удаляем notifier через provider
    final notifier = ref.read(seatSetupProviderFamily(_params).notifier);
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final leftSeats = [5, 4, 3, 2, 1];
    final rightSeats = [6, 7, 8, 9, 10];

    // 🔥 Подписываемся на состояние
    final state = ref.watch(seatSetupProviderFamily(_params));
    final notifier = ref.read(seatSetupProviderFamily(_params).notifier);

    // Обновляем контроллеры если изменились данные
    notifier.updateControllersFromData();

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
                      controllers: state.nameControllers,
                      textFieldKeys: state.textFieldKeys,
                      onTap: (index) => notifier.onPlayerTap(index, context),
                      onChanged: notifier.onPlayerChanged,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: SeatPlayerList(
                      seats: rightSeats,
                      isLeft: false,
                      controllers: state.nameControllers,
                      textFieldKeys: state.textFieldKeys,
                      onTap: (index) => notifier.onPlayerTap(index, context),
                      onChanged: notifier.onPlayerChanged,
                    ),
                  ),
                ],
              ),
            ),
            // ===== НАСТРОЙКИ =====
            const SizedBox(height: 8),
            SeatSettingsRow(
              tournamentController: state.tournamentController,
              stageController: state.stageController,
              tableController: state.tableController,
              gameController: state.gameController,
              selectedDate: state.selectedDate,
              months: state.months,
              onDateTap: () => _selectDateTime(context),
              onChanged: notifier._notifyChanges,
            ),
            const SizedBox(height: 8),
            // ===== КНОПКА НОВАЯ ИГРА =====
            GameNewButton(
              label: 'СОЗДАТЬ НОВУЮ ИГРУ',
              isFullWidth: true,
              onNewGame: notifier.resetSeats,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final theme = Theme.of(context);
    final state = ref.read(seatSetupProviderFamily(_params));
    final notifier = ref.read(seatSetupProviderFamily(_params).notifier);

    final picked = await showDatePicker(
      context: context,
      initialDate: state.selectedDate,
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
        initialTime: TimeOfDay.fromDateTime(state.selectedDate),
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
        notifier.selectDateTime(picked, time);
      }
    }
  }
}