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
  final VoidCallback onStartGame;  // 🔥 ДОБАВЛЯЕМ

  const SeatSetupScreen({
    super.key,
    required this.initialData,
    required this.onNamesChanged,
    required this.onStartGame,  // 🔥 ДОБАВЛЯЕМ
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
    ref.read(seatSetupProviderFamily(_params));
  }

  @override
  void dispose() {
    final notifier = ref.read(seatSetupProviderFamily(_params).notifier);
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final leftSeats = [5, 4, 3, 2, 1];
    final rightSeats = [6, 7, 8, 9, 10];

    final state = ref.watch(seatSetupProviderFamily(_params));
    final notifier = ref.read(seatSetupProviderFamily(_params).notifier);

    // 🔥 ПРОВЕРКА СОСТОЯНИЯ ДЛЯ КНОПКИ
    final allFilled = state.nameControllers.every((c) => c.text.trim().isNotEmpty);
    final names = state.nameControllers.map((c) => c.text.trim().toLowerCase()).toList();
    final uniqueNames = names.toSet();
    final hasDuplicates = uniqueNames.length < names.length && allFilled;
    final canStart = allFilled && !hasDuplicates;

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
                    child: SeatPlayerList(
                      seats: leftSeats,
                      isLeft: true,
                      controllers: state.nameControllers,
                      avatarUrls: state.avatarUrls,
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
                      avatarUrls: state.avatarUrls,
                      onTap: (index) => notifier.onPlayerTap(index, context),
                      onChanged: notifier.onPlayerChanged,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SeatSettingsRow(
              tournamentController: state.tournamentController,
              stageController: state.stageController,
              tableController: state.tableController,
              gameController: state.gameController,
              selectedDate: state.selectedDate,
              months: state.months,
              onDateTap: () => _selectDateTime(context, state, notifier),
              onChanged: notifier.notifyChanges,
            ),
            const SizedBox(height: 8),
            // 🔥 ДВЕ КНОПКИ В РЯД
            Row(
              children: [
                Expanded(
                  child: GameNewButton(
                    label: 'УДАЛИТЬ ИГРУ',
                    isFullWidth: true,
                    onNewGame: notifier.resetSeats,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStartButton(context, canStart, notifier),
                ),
              ],
            ),
            // 🔥 ПОДПИСЬ (ЕСЛИ НЕЛЬЗЯ НАЧАТЬ)
            if (!canStart) ...[
              const SizedBox(height: 4),
              _buildStatusMessage(hasDuplicates, allFilled),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 🔥 КНОПКА "НАЧАТЬ"
  Widget _buildStartButton(
    BuildContext context,
    bool canStart,
    SeatSetupNotifier notifier,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: canStart
            ? () {
                // 🔥 СОХРАНЯЕМ ИМЕНА
                notifier.notifyChanges();
                // 🔥 ПЕРЕХОДИМ НА ВКЛАДКУ ИГРЫ
                widget.onStartGame();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canStart
              ? Colors.green
              : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
          foregroundColor: canStart
              ? Colors.white
              : (isDark ? Colors.grey.shade600 : Colors.grey.shade600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_arrow,
              size: 20,
              color: canStart ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              'НАЧАТЬ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: canStart ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 ПОДПИСЬ СТАТУСА
  Widget _buildStatusMessage(bool hasDuplicates, bool allFilled) {
    String message;
    Color color;

    if (hasDuplicates) {
      message = '⚠️ Имена не должны повторяться';
      color = Colors.red;
    } else if (!allFilled) {
      message = '⚠️ Заполните всех 10 игроков';
      color = Colors.orange;
    } else {
      message = '';
      color = Colors.transparent;
    }

    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        message,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _selectDateTime(
    BuildContext context,
    SeatSetupState state,
    SeatSetupNotifier notifier,
  ) async {
    final theme = Theme.of(context);

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