// lib/presentation/screens/seat_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'lobby_screen.dart';

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
  late TextEditingController _tournamentController;
  late TextEditingController _stageController;
  late TextEditingController _tableController;
  late TextEditingController _gameController;
  late List<TextEditingController> _nameControllers;
  late DateTime _selectedDate;

  final List<String> _months = [
    'ЯНВАРЬ', 'ФЕВРАЛЬ', 'МАРТ', 'АПРЕЛЬ', 'МАЙ', 'ИЮНЬ',
    'ИЮЛЬ', 'АВГУСТ', 'СЕНТЯБРЬ', 'ОКТЯБРЬ', 'НОЯБРЬ', 'ДЕКАБРЬ'
  ];

  final List<int> _leftSeats = [5, 4, 3, 2, 1];
  final List<int> _rightSeats = [6, 7, 8, 9, 10];

  @override
  void initState() {
    super.initState();

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

    _nameControllers = List.generate(10, (index) {
      return TextEditingController(
        text: widget.initialData.playerNames.length > index
            ? widget.initialData.playerNames[index]
            : '',
      );
    });
  }

  @override
  void dispose() {
    _tournamentController.dispose();
    _stageController.dispose();
    _tableController.dispose();
    _gameController.dispose();
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
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
      tournamentName: _tournamentController.text,
      stageName: _stageController.text,
      tableNumber: int.tryParse(_tableController.text) ?? 1,
      gameNumber: int.tryParse(_gameController.text) ?? 1,
      gameDate: _selectedDate,
      judgeName: widget.initialData.judgeName,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===== НАСТРОЙКИ ИГРЫ =====
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Настройки игры',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          context,
                          controller: _tableController,
                          label: 'Стол',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _notifyChanges(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          context,
                          controller: _gameController,
                          label: 'Игра',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _notifyChanges(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDateTimePicker(context),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 16,
                        color: isDark ? Colors.grey : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Судья: ${widget.initialData.judgeName}',
                        style: TextStyle(
                          color: isDark ? Colors.grey : Colors.grey.shade600,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===== ИГРОКИ =====
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Игроки',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPlayersColumn(_leftSeats, isLeft: true),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildPlayersColumn(_rightSeats, isLeft: false),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

  Widget _buildPlayersColumn(List<int> seats, {required bool isLeft}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: seats.map((seat) {
        final index = seat - 1;
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
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
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: _nameControllers[index],
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                    fontSize: 14,
                  ),
                  onChanged: (_) => _notifyChanges(),
                  decoration: InputDecoration(
                    hintText: 'Игрок $seat',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                  ),
                  textAlign: isLeft ? TextAlign.left : TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
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
}