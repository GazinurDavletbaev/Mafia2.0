// lib/presentation/screens/game_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/presentation/screens/lobby_screen.dart';

class GameSettingsScreen extends ConsumerStatefulWidget {
  final GameData initialData;
  final Function(GameData) onSettingsChanged;
    onNewGame: _onNewGame,  // ← передаём метод


  const GameSettingsScreen({
    super.key,
    required this.initialData,
    required this.onSettingsChanged,
  });

  @override
  ConsumerState<GameSettingsScreen> createState() => _GameSettingsScreenState();
}

class _GameSettingsScreenState extends ConsumerState<GameSettingsScreen> {
  late TextEditingController _tournamentController;
  late TextEditingController _stageController;
  late TextEditingController _tableController;
  late TextEditingController _gameController;
  late TextEditingController _judgeController;
  late DateTime _selectedDate;

  // ✅ Месяца для автоматического заполнения
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

    // ✅ Если стадия пустая — ставим текущий месяц
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
    _judgeController = TextEditingController(
      text: widget.initialData.judgeName,
    );
    _selectedDate = widget.initialData.date;
  }

  @override
  void dispose() {
    _tournamentController.dispose();
    _stageController.dispose();
    _tableController.dispose();
    _gameController.dispose();
    _judgeController.dispose();
    super.dispose();
  }

  void _notifyChanges() {
    widget.onSettingsChanged(
      GameData(
        tournamentName: _tournamentController.text,
        stageName: _stageController.text,
        tableNumber: int.tryParse(_tableController.text) ?? 1,
        gameNumber: int.tryParse(_gameController.text) ?? 1,
        date: _selectedDate,
        judgeName: _judgeController.text,
        playerNames: widget.initialData.playerNames,
        gameState: widget.initialData.gameState.copyWith(
          tournamentName: _tournamentController.text,
          stageName: _stageController.text,
          tableNumber: int.tryParse(_tableController.text) ?? 1,
          gameNumber: int.tryParse(_gameController.text) ?? 1,
          gameDate: _selectedDate,
          judgeName: _judgeController.text,
        ),
        gameHistory: widget.initialData.gameHistory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Настройки игры'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            _buildTextField(
              context,
              controller: _tournamentController,
              label: 'Турнир',
              hint: 'Введите название турнира',
              onChanged: (_) => _notifyChanges(),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              context,
              controller: _stageController,
              label: 'Стадия',
              hint: 'Введите название стадии',
              onChanged: (_) => _notifyChanges(),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              context,
              controller: _tableController,
              label: 'Номер стола',
              keyboardType: TextInputType.number,
              onChanged: (_) => _notifyChanges(),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              context,
              controller: _gameController,
              label: 'Номер игры',
              keyboardType: TextInputType.number,
              onChanged: (_) => _notifyChanges(),
            ),
            const SizedBox(height: 16),
            _buildDateTimePicker(context),
            const SizedBox(height: 16),
            _buildTextField(
              context,
              controller: _judgeController,
              label: 'Судья (никнейм)',
              hint: 'Введите имя судьи',
              onChanged: (_) => _notifyChanges(),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(
        color: theme.textTheme.bodyLarge?.color ?? Colors.white,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.grey : Colors.grey.shade600,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
        ),
        filled: true,
        fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () => _selectDateTime(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDate.toString().substring(0, 16),
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                fontSize: 16,
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: isDark ? Colors.grey : Colors.grey.shade600,
            ),
          ],
        ),
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
          // ✅ Обновляем стадию при изменении даты
          _stageController.text = _months[_selectedDate.month - 1];
          _notifyChanges();
        });
      }
    }
  }
}
